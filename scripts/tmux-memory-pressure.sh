#!/usr/bin/env bash

if [ "$(uname)" != "Darwin" ]; then
  exit 0
fi

pressure_level="$(sysctl -n kern.memorystatus_vm_pressure_level 2> /dev/null || printf '')"
memory_level="$(sysctl -n kern.memorystatus_level 2> /dev/null || printf '')"

color='#[fg=#fab387]'
label="lvl:${pressure_level}"

# macOS observed values:
# 1 = normal, 2 = warn, 4+ = critical
case "$pressure_level" in
  1)
    color='#[fg=green]'
    label='󰄬 '
    ;;
  2)
    color='#[fg=yellow]'
    label='󰀦 '
    ;;
  4 | 8 | 16)
    color='#[fg=red]'
    label='󰚌 '
    ;;
  '')
    exit 0
    ;;
  *)
    if [ -n "$memory_level" ]; then
      label="${label} ${memory_level}%"
    fi
    ;;
esac

printf '%s%s' "$color" "$label"
