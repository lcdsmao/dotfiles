export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# https://developer.android.com/tools/adb#mdnsBackends
export ADB_MDNS_OPENSCREEN=1

alias gn='./gradlew'
alias gkill='pkill -9 -l -f gradle-launcher'

function adblink() { adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "'$1'"; }
function adbtext() { adb shell input text "'$1'"; }

function adbsp() { adb shell pm list package -3 | fzf | cut -d':' -f2; }

alias lcg="adb logcat -v color"
alias lccrash="lcg AndroidRuntime:E '*:S'" # prints only Crash logs, if AndroidStudio is not working use this command.
function lctag() { lcg "$1":V '*:S'; }
function lcapp() { lcg --pid="$(adb shell pidof -s "$(adbsp)")"; }

function adbanim() {
    local factor=${1:-1}
    adb shell settings put global window_animation_scale "$factor"
    adb shell settings put global transition_animation_scale "$factor"
    adb shell settings put global animator_duration_scale "$factor"
}

function adbproxy() {
    local arg="$1"
    local host

    if [ -z "$arg" ]; then
        adb shell settings get global http_proxy
        return $?
    fi

    host="$(ipconfig getifaddr en0)"
    if [ "$arg" = "-" ]; then
        adb shell settings put global http_proxy "${host}:8889"
    elif [ "$arg" = "0" ]; then
        adb shell settings put global http_proxy :0
    elif [[ "$arg" =~ ^[0-9]+$ ]]; then
        adb shell settings put global http_proxy "${host}:${arg}"
    else
        adb shell settings put global http_proxy "$arg"
    fi

    adb shell settings get global http_proxy
}

function adbam() {
    local mode="${1:-0}"
    if [ "$mode" = "1" ]; then
        adb shell cmd connectivity airplane-mode disable
    else
        adb shell cmd connectivity airplane-mode enable
    fi
}

function avdr() {
    selected_avd="$(emulator -list-avds | fzf)" && (emulator @"$selected_avd" "$@" > /dev/null 2>&1 &)
}

function adbshot() {
    DATE=$(date '+%y%m%d%H%M%S')
    FILE_NAME=screenshot-${DATE}.png
    DIR_PATH=~/Desktop
    adb shell screencap -p > "${DIR_PATH}/${FILE_NAME}"
}

function adbrecord() {
    DATE=$(date '+%y%m%d%H%M%S')
    FILE_NAME=record-${DATE}
    YOUR_PATH=~/Desktop

    selected_device=$(adbs)
    adb -s "$selected_device" shell screenrecord /sdcard/"$FILE_NAME".mp4 &
    pid=$(ps x | grep -v grep | grep "shell screenrecord" | awk '{ print $1 }')

    if [ -z "$pid" ]; then
        printf "Not running a screenrecord."
        return 1
    fi

    printf "Recording, finish? [y]"
    while read -r isFinished; do
        case "$isFinished" in
            "y" | "Y") break ;;
            *) printf "Incorrect value." ;;
        esac
    done

    kill -9 "$pid" # Finished the process of adb screenrecord
    while :; do
        alive=$(adb -s "$selected_device" shell ps | grep screenrecord | grep -v grep | awk '{ print $9 }')
        if [ -z "$alive" ]; then
            break
        fi
    done

    printf "Finished the recording process : %s\nSending to %s...\n" "$pid" "$YOUR_PATH"
    command adb -s "$selected_device" pull /sdcard/"${FILE_NAME}".mp4 $YOUR_PATH
    command adb -s "$selected_device" shell rm /sdcard/"${FILE_NAME}".mp4

    echo "Converts to GIF? [y]"
    read -r convertGif
    case $convertGif in
        "y" | "Y") ffmpeg -i "${YOUR_PATH}/${FILE_NAME}.mp4" -an -r 15 -pix_fmt rgb24 -f gif "${YOUR_PATH}/${FILE_NAME}.gif" ;; # creating gif
        *) ;;
    esac
}

function scrcpy() {
    command scrcpy -s "$(adbs)" "$@"
}

# Function to interactively select an ADB device and return its serial number.
# Usage: serial=$(adbs)
function adbs() {
    # Check if 'fzf' is installed
    if ! command -v fzf > /dev/null 2>&1; then
        echo "Error: fzf is not installed." >&2
        return 1
    fi

    # Get the detailed list of connected devices
    # We skip the header line and any empty lines
    local devices_detailed
    devices_detailed=$(command adb devices -l | sed '1d' | grep -v '^$')

    if [ -z "$devices_detailed" ]; then
        echo "Error: No devices/emulators found." >&2
        return 1
    fi

    local device_count
    device_count=$(echo "$devices_detailed" | wc -l | awk '{print $1}')

    if [ "$device_count" -eq 1 ]; then
        # If only one device, return it directly without prompt
        echo "$devices_detailed" | awk '{print $1}'
    else
        # Multiple devices: use fzf to pick one
        local selection
        selection=$(echo "$devices_detailed" | fzf --height 40% --reverse --prompt="Select ADB Device: " --header="Multiple devices found:")

        if [ -n "$selection" ]; then
            # Extract and return only the serial number
            echo "$selection" | awk '{print $1}'
        else
            return 1
        fi
    fi
}

# A smart wrapper for the 'adb' command and a standalone device selector.
function adb() {
    # Check if 'fzf' is installed
    if ! command -v fzf > /dev/null 2>&1; then
        command adb "$@"
        return $?
    fi

    local first_arg="$1"
    local needs_target=true

    # If no arguments, just run standard adb (which shows help)
    if [ -z "$first_arg" ]; then
        command adb
        return $?
    fi

    # Check if the command is in the skip list
    # Using a case statement here is the most portable way to check
    # against multiple strings in both Bash and Zsh without array issues.
    case "$first_arg" in
        devices | help | version | start-server | kill-server | connect | disconnect)
            needs_target=false
            ;;
    esac

    # Check if user already provided a target flag (-s)
    # Only consider flags before the subcommand.
    local has_target=false
    for arg in "$@"; do
        if [ "$arg" = "--" ]; then
            break
        fi
        case "$arg" in
            -*)
                case "$arg" in
                    -s)
                        has_target=true
                        break
                        ;;
                esac
                ;;
            *)
                break
                ;;
        esac
    done

    # If we already have a target flag or don't need a target, pass through immediately
    if [ "$has_target" = true ] || [ "$needs_target" = false ]; then
        command adb "$@"
        return $?
    fi

    # Check for devices
    local devices_list
    devices_list=$(command adb devices | sed '1d' | grep -v '^$')

    if [ -z "$devices_list" ]; then
        command adb "$@"
        return $?
    fi

    local device_count
    device_count=$(echo "$devices_list" | wc -l | awk '{print $1}')

    if [ "$device_count" -le 1 ]; then
        command adb "$@"
    else
        # Use the adbs function for selection
        local selected_device
        selected_device=$(adbs)

        if [ -n "$selected_device" ]; then
            echo "Targeting device: $selected_device"
            command adb -s "$selected_device" "$@"
        else
            echo "Selection cancelled."
            return 1
        fi
    fi
}
