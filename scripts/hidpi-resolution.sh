#!/usr/bin/env bash
# Manage custom macOS HiDPI display modes without BetterDisplay.
# `suggest` calculates a mode, `install` writes the display override, and
# `apply` selects an installed mode. Installation requires a reconnect/reboot.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly OVERRIDE_ROOT="/Library/Displays/Contents/Resources/Overrides"
readonly CACHE_DIR="${HOME}/Library/Caches/hidpi-resolution"
readonly HELPER="${CACHE_DIR}/hidpi-mode"

logical_width=""
logical_height=""
refresh_rate=60
scale=""
width_set=0
height_set=0
display_id=""
display_name=""
force=0

usage() {
	local exit_code="${1:-64}"
	cat <<'EOF'
Usage:
  hidpi-resolution.sh list
  hidpi-resolution.sh modes --name DISPLAY_NAME
  hidpi-resolution.sh suggest --name DISPLAY_NAME --scale SCALE
  hidpi-resolution.sh install --name DISPLAY_NAME [options]
  hidpi-resolution.sh apply --name DISPLAY_NAME [options]
  hidpi-resolution.sh remove --name DISPLAY_NAME

Options:
  --name NAME          select a display by name (recommended)
  --id ID              select by macOS display ID (use for duplicate names)
  --width WIDTH        logical HiDPI width (requires --height)
  --height HEIGHT      logical HiDPI height (requires --width)
  --scale SCALE        infer dimensions from native size (alternative to width/height)
  --refresh HZ         preferred refresh rate (default: 60)
  --force              replace an existing display override after backing it up

Defaults:
  Refresh rate: 60Hz
  Dimensions: pass --scale or both --width and --height.

Examples:
  ./hidpi-resolution.sh list
  ./hidpi-resolution.sh suggest --name 'VG34VQL3A' --scale 1.25
  ./hidpi-resolution.sh install --name 'VG34VQL3A' --scale 1.25
  ./hidpi-resolution.sh apply --name 'VG34VQL3A' --scale 1.25
  ./hidpi-resolution.sh remove --name 'VG34VQL3A'

The install command writes a macOS display override and requires a reboot or
logout/login before the new mode is visible. It does not change the monitor's
physical timing; it adds a HiDPI desktop mode.
EOF
	exit "$exit_code"
}

die() {
	printf '%s\n' "hidpi-resolution: $*" >&2
	exit 1
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

list_displays() {
	/usr/sbin/system_profiler SPDisplaysDataType
}

# Reads the JSON emitted by system_profiler without requiring jq. The last
# _name before a display ID is the display name (not the GPU name).
metadata_for_display() {
	local selector="$1"
	/usr/sbin/system_profiler SPDisplaysDataType -json | /usr/bin/awk \
		-v selector="$selector" '
        function value(s) {
            sub(/.*: "/, "", s)
            sub(/".*/, "", s)
            return s
        }
        /"_name"[[:space:]]*:/ { name = value($0) }
        /"_spdisplays_display-product-id"[[:space:]]*:/ { product = value($0) }
        /"_spdisplays_display-vendor-id"[[:space:]]*:/ { vendor = value($0) }
        /"_spdisplays_displayID"[[:space:]]*:/ {
            id = value($0)
            if (id == selector || name == selector) {
                print id "\t" name "\t" vendor "\t" product
                exit
            }
        }
    '
}

resolve_display() {
	if [[ -n "$display_id" && -n "$display_name" ]]; then
		die "use only one of --id and --name"
	fi

	if [[ -z "$display_id" && -z "$display_name" ]]; then
		die "provide --id or --name"
	fi

	local selector="${display_id:-$display_name}"
	local metadata
	metadata="$(metadata_for_display "$selector")" || true
	[[ -n "$metadata" ]] || die "display not found: $selector"

	IFS=$'\t' read -r display_id display_name vendor_hex product_hex <<<"$metadata"
	[[ -n "$vendor_hex" && -n "$product_hex" ]] || die "could not read vendor/product IDs for $display_name"
}

hex_to_decimal() {
	printf '%d' "0x$1"
}

base64_be32_pair() {
	local first="$1"
	local second="$2"
	printf '%08x%08x' "$first" "$second" | /usr/bin/xxd -r -p | /usr/bin/base64 | tr -d '\n'
}

base64_be32_quad() {
	local first="$1"
	local second="$2"
	local third="$3"
	local fourth="$4"
	printf '%08x%08x%08x%08x' "$first" "$second" "$third" "$fourth" |
		/usr/bin/xxd -r -p | /usr/bin/base64 | tr -d '\n'
}

calculate_dimensions_from_scale() {
	[[ -n "$scale" ]] || die "--scale needs a value"
	[[ "$width_set" == 0 && "$height_set" == 0 ]] || die "do not combine --scale with --width or --height"
	[[ "$scale" =~ ^[0-9]+([.][0-9]+)?$ ]] || die "scale must be a positive number, for example 1.25"

	compile_helper
	local native_dimensions
	native_dimensions="$("$HELPER" native "$display_id")"
	local native_width native_height
	IFS=$'\t' read -r native_width native_height <<<"$native_dimensions"
	[[ -n "$native_width" && -n "$native_height" ]] || die "could not infer native display dimensions"

	logical_width="$(/usr/bin/awk -v n="$native_width" -v s="$scale" 'BEGIN { printf "%d", n / s + 0.5 }')"
	logical_height="$(/usr/bin/awk -v n="$native_height" -v s="$scale" 'BEGIN { printf "%d", n / s + 0.5 }')"
	printf '%s\n' "Native panel: ${native_width}x${native_height}"
	printf '%s\n' "UI scale: ${scale}x"
	printf '%s\n' "Logical HiDPI desktop: ${logical_width}x${logical_height}"
	printf '%s\n' "HiDPI framebuffer: $((logical_width * 2))x$((logical_height * 2))"
}

validate_dimensions() {
	if [[ -n "$scale" ]]; then
		die "use --scale instead of --width or --height"
	fi
	[[ "$width_set" == 1 && "$height_set" == 1 ]] || die "provide both --width and --height, or use --scale"
	[[ "$logical_width" =~ ^[0-9]+$ && "$logical_height" =~ ^[0-9]+$ ]] || die "width and height must be positive integers"
	[[ "$logical_width" -gt 0 && "$logical_height" -gt 0 ]] || die "width and height must be positive integers"
}

override_path() {
	local vendor_hex_lower
	local product_hex_lower
	vendor_hex_lower="$(printf '%s' "$vendor_hex" | tr '[:upper:]' '[:lower:]')"
	product_hex_lower="$(printf '%s' "$product_hex" | tr '[:upper:]' '[:lower:]')"
	printf '%s\n' "${OVERRIDE_ROOT}/DisplayVendorID-${vendor_hex_lower}/DisplayProductID-${product_hex_lower}"
}

write_override() {
	local override_file="$1"
	local vendor_decimal
	local product_decimal
	local double_width
	local double_height
	local logical_data
	local hidpi_data
	local hidpi_descriptor
	local temporary
	vendor_decimal="$(hex_to_decimal "$vendor_hex")"
	product_decimal="$(hex_to_decimal "$product_hex")"
	double_width=$((logical_width * 2))
	double_height=$((logical_height * 2))
	logical_data="$(base64_be32_pair "$logical_width" "$logical_height")"
	hidpi_data="$(base64_be32_pair "$double_width" "$double_height")"
	# This is the same HiDPI descriptor format used by macOS display overrides.
	hidpi_descriptor="$(base64_be32_quad "$double_width" "$double_height" 9 2097152)"
	temporary="$(mktemp -t hidpi-resolution).plist"

	cat >"$temporary" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>DisplayProductID</key>
    <integer>${product_decimal}</integer>
    <key>DisplayVendorID</key>
    <integer>${vendor_decimal}</integer>
    <key>scale-resolutions</key>
    <array>
        <data>${logical_data}</data>
        <data>${hidpi_descriptor}</data>
        <data>${hidpi_data}</data>
    </array>
</dict>
</plist>
EOF

	if [[ -e "$override_file" && "$force" != 1 ]]; then
		rm -f "$temporary"
		die "$override_file already exists; use --force to back it up and replace it"
	fi

	if [[ -e "$override_file" ]]; then
		if [[ ! -e "${override_file}.before-hidpi-resolution" ]]; then
			printf '%s\n' "Backing up existing override to ${override_file}.before-hidpi-resolution"
			sudo cp -p "$override_file" "${override_file}.before-hidpi-resolution"
		else
			printf '%s\n' "Keeping existing backup at ${override_file}.before-hidpi-resolution"
		fi
	fi

	printf '%s\n' "Installing override for ${display_name} (${vendor_hex}/${product_hex})"
	sudo mkdir -p "$(dirname "$override_file")"
	sudo /usr/bin/install -o root -g wheel -m 644 "$temporary" "$override_file"
	rm -f "$temporary"
}

compile_helper() {
	local swiftc_path="/usr/bin/swiftc"
	[[ -x "$swiftc_path" ]] || die "Swift compiler not found at $swiftc_path; install Xcode Command Line Tools"
	mkdir -p "$CACHE_DIR"
	if [[ ! -x "$HELPER" || "$SCRIPT_DIR/hidpi-mode.swift" -nt "$HELPER" ]]; then
		"$swiftc_path" -O "$SCRIPT_DIR/hidpi-mode.swift" -o "$HELPER"
	fi
}

parse_options() {
	while (($# > 0)); do
		case "$1" in
		--id)
			(($# >= 2)) || die "--id needs a value"
			display_id="$2"
			shift 2
			;;
		--id=*)
			display_id="${1#*=}"
			shift
			;;
		--name)
			(($# >= 2)) || die "--name needs a value"
			display_name="$2"
			shift 2
			;;
		--name=*)
			display_name="${1#*=}"
			shift
			;;
		--width)
			(($# >= 2)) || die "--width needs a value"
			logical_width="$2"
			width_set=1
			shift 2
			;;
		--width=*)
			logical_width="${1#*=}"
			width_set=1
			shift
			;;
		--height)
			(($# >= 2)) || die "--height needs a value"
			logical_height="$2"
			height_set=1
			shift 2
			;;
		--height=*)
			logical_height="${1#*=}"
			height_set=1
			shift
			;;
		--refresh)
			(($# >= 2)) || die "--refresh needs a value"
			refresh_rate="$2"
			shift 2
			;;
		--refresh=*)
			refresh_rate="${1#*=}"
			shift
			;;
		--scale)
			(($# >= 2)) || die "--scale needs a value"
			scale="$2"
			shift 2
			;;
		--scale=*)
			scale="${1#*=}"
			shift
			;;
		--force)
			force=1
			shift
			;;
		-h | --help) usage 0 ;;
		*) die "unknown option: $1" ;;
		esac
	done
}

main() {
	(($# >= 1)) || usage 0
	[[ "$1" == "-h" || "$1" == "--help" ]] && usage 0
	local operation="$1"
	shift

	case "$operation" in
	list)
		(($# == 0)) || die "list takes no options"
		list_displays
		;;
	modes | suggest | install | apply | remove)
		parse_options "$@"
		resolve_display
		local override_file
		override_file="$(override_path)"

		case "$operation" in
		modes)
			[[ -z "$scale" ]] || die "--scale is only supported by suggest, install, and apply"
			compile_helper
			"$HELPER" list "$display_id"
			;;
		suggest)
			calculate_dimensions_from_scale
			;;
		install)
			if [[ -n "$scale" ]]; then
				calculate_dimensions_from_scale
			else
				validate_dimensions
			fi
			write_override "$override_file"
			printf '\n'
			printf '%s\n' "Installed. Reboot, or log out and back in, then run:"
			if [[ -n "$scale" ]]; then
				printf '%s\n' "  $0 apply --id $display_id --scale $scale"
			else
				printf '%s\n' "  $0 apply --id $display_id --width $logical_width --height $logical_height"
			fi
			;;
		apply)
			if [[ -n "$scale" ]]; then
				calculate_dimensions_from_scale
			else
				validate_dimensions
			fi
			compile_helper
			"$HELPER" apply "$display_id" "$logical_width" "$logical_height" "$refresh_rate"
			;;
		remove)
			if [[ -f "${override_file}.before-hidpi-resolution" ]]; then
				printf '%s\n' "Restoring ${override_file}.before-hidpi-resolution"
				sudo cp -p "${override_file}.before-hidpi-resolution" "$override_file"
			elif [[ -f "$override_file" ]]; then
				printf '%s\n' "Removing $override_file"
				sudo rm "$override_file"
			else
				die "no override found at $override_file"
			fi
			printf '%s\n' "Reboot, or log out and back in, to remove the mode."
			;;
		esac
		;;
	*) die "unknown operation: $operation" ;;
	esac
}

main "$@"
