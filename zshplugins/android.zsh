export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# https://developer.android.com/tools/adb#mdnsBackends
export ADB_MDNS_OPENSCREEN=1

alias gn='./gradlew'
alias gkill='pkill -9 -l -f gradle-launcher'

function adblink() { adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "'$1'"; }
alias adbtext='adb shell input text ' # to enter text input to your device

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

alias adbgproxy='adb shell settings get global http_proxy;'
alias adbsproxy='adb shell settings put global http_proxy $(ipconfig getifaddr en0):8889;'
alias adbrproxy='adb shell settings put global http_proxy :0'
alias adbeam='adb shell cmd connectivity airplane-mode enable'
alias adbdam='adb shell cmd connectivity airplane-mode disable'

function adbt() {
  case "$1" in
    -a)
      export _adb_type="ALL"
      echo "adb type: ALL"
      ;;
    -f)
      export _adb_type="FZF"
      echo "adb type: FZF"
      ;;
    -d)
      unset _adb_type
      echo "adb type: DEFAULT"
      ;;
    *)
      export _adb_type="ONE"
      echo "adb type: ONE"
      ;;
  esac
}

function adb() {
  case "$_adb_type" in
    "ALL")
      adb_all "$@"
      ;;
    "FZF")
      adb_fzf "$@"
      ;;
    "ONE")
      adb_one "$@"
      ;;
    *)
      command adb "$@"
      ;;

  esac
}

function adb_all() {
  local ds=()
  while IFS='' read -r line; do ds+=("$line"); done < <(command adb devices | awk 'NR > 1 {print $1 }')
  for i in "${ds[@]}"; do
    [[ -n $i ]] && command adb -s "$i" "$@"
  done
}

function adb_one() {
  local ds=()
  while IFS='' read -r line; do ds+=("$line"); done < <(command adb devices | awk 'NR > 1')
  for i in "${ds[@]}"; do
    read -r device state <<< "$i"
    if [[ $state = "device" ]]; then
      command adb -s "$device" "$@"
      break
    fi
  done
}

function adbshot() {
  DATE=$(date '+%y%m%d%H%M%S')
  FILE_NAME=screenshot-${DATE}.png
  DIR_PATH=~/Desktop

  local selected_dev
  selected_dev=$(adb_select_device)
  command adb -s "$selected_dev" shell screencap -p > "${DIR_PATH}/${FILE_NAME}"
}

function adbrecord() {
  DATE=$(date '+%y%m%d%H%M%S')
  FILE_NAME=record-${DATE}
  YOUR_PATH=~/Desktop

  local selected_dev
  selected_dev=$(adb_select_device)

  command adb -s "$selected_dev" shell screenrecord /sdcard/"$FILE_NAME".mp4 &
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
    alive=$(command adb -s "$selected_dev" shell ps | grep screenrecord | grep -v grep | awk '{ print $9 }')
    if [ -z "$alive" ]; then
      break
    fi
  done

  printf "Finished the recording process : %s\nSending to %s...\n" "$pid" "$YOUR_PATH"
  command adb -s "$selected_dev" pull /sdcard/"${FILE_NAME}".mp4 $YOUR_PATH
  command adb -s "$selected_dev" shell rm /sdcard/"${FILE_NAME}".mp4

  echo "Converts to GIF? [y]"
  read -r convertGif
  case $convertGif in
    "y" | "Y") ffmpeg -i "${YOUR_PATH}/${FILE_NAME}.mp4" -an -r 15 -pix_fmt rgb24 -f gif "${YOUR_PATH}/${FILE_NAME}.gif" ;; # creating gif
    *) ;;
  esac
}

function adbwifi() {
  adb tcpip 5555 \
    && sleep 1 \
    && ip=$(adb shell "ip addr show wlan0 | grep -e wlan0$ | cut -d\" \" -f 6 | cut -d/ -f 1") \
    && adb connect "$ip":5555
}
