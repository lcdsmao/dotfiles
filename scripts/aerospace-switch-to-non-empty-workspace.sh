#!/usr/bin/env bash

set -euo pipefail

direction="${1:-next}"

if [ "$direction" != "next" ] && [ "$direction" != "prev" ]; then
	echo "Usage: $0 [next|prev]" >&2
	exit 1
fi

current_workspace="$(aerospace list-workspaces --focused)"
non_empty_workspaces="$(aerospace list-workspaces --monitor focused --empty no)"

if [ -z "$non_empty_workspaces" ]; then
	exit 0
fi

workspaces=()
while IFS= read -r workspace; do
	[ -z "$workspace" ] && continue
	workspaces+=("$workspace")
done <<EOF
$non_empty_workspaces
EOF

workspace_count="${#workspaces[@]}"
[ "$workspace_count" -eq 0 ] && exit 0

current_index=-1
for i in "${!workspaces[@]}"; do
	if [ "${workspaces[$i]}" = "$current_workspace" ]; then
		current_index="$i"
		break
	fi
done

if [ "$current_index" -lt 0 ]; then
	if [ "$direction" = "next" ]; then
		target_workspace="${workspaces[0]}"
	else
		target_workspace="${workspaces[$((workspace_count - 1))]}"
	fi
else
	if [ "$direction" = "next" ]; then
		target_workspace="${workspaces[$(((current_index + 1) % workspace_count))]}"
	else
		target_workspace="${workspaces[$(((current_index - 1 + workspace_count) % workspace_count))]}"
	fi
fi

[ "$target_workspace" = "$current_workspace" ] && exit 0

aerospace workspace "$target_workspace"
