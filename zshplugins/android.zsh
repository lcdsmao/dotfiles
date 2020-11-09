export appId='<Replace with ApplicationId like com.abc.def>'
export mainActivityName='<Replace with MainActivity of your app like com.abc.def.MainActivity>'
export buildVariantTarget='iD' # Default to installDebug (iD) ; Replace it with your default buildVariantType
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools
alias gn='./gradlew'
alias latestapkname='ls -tr | grep '.apk' | tail -1 | pbcopy'            # copy latestApk file name in current folder to clipboard.
alias adbca="adb shell dumpsys window windows | grep -E 'mCurrentFocus'" # show current activity name
alias gkill='pkill -9 -l -f gradle-launcher'

function sta() { adb shell am start -n "$appId"/"$mainActivityName"; } # start app
function stp() { adb shell am force-stop "$appId"; }                   # force stop app
function clr() { adb shell pm clear "$appId"; }                        # clear data of app
function uns() { adb uninstall "$appId"; }                             # uninstall app
function iturl() { adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "$1"; }

# Build with buildVariantTarget flavor then install App  then start it
function bld() {
    [[ $1 == "c" ]] && gn clean
    gn "$buildVariantTarget" && sta
}

# Uninstall App then Build with buildVariantTarget flavor then install App & then start it
function bldu() {
    uns && gn "$buildVariantTarget" && sta
}

# use updateAppId com.random.otherapp to change it for that tab.
function updateappid() {
    [[ -n $1 ]] && appId="$1"
}

function updatemainactivity() { if [[ -n $1 ]]; then mainActivityName="$1"; fi; }
function updatebuildtype() { if [[ -n $1 ]]; then buildVariantTarget="$1"; fi; }
function printvariables() {
    echo "appId = $appId
    mainActivityName = $mainActivityName
    buildVariantTarget = $buildVariantTarget"
}

alias ins='uns && adb install ' # Uninstall App then install with existing app path
alias upg='adb install -r '
function upglatest() { latestapkname && upg "$(pbpaste)" && sta; } # Upgrade app with latest updated apk in current folder
function atest() { gn test connectedAndroidTest; }                 # execute all tests

alias text='adb shell input text ' # to enter text input to your device

alias lcr="adb logcat -v color AndroidRuntime:E '*:S'" # prints only Crash logs, if AndroidStudio is not working use this command.
function lctag() { adb logcat -v color "$1":V '*:S'; }
function lcapp() { adb logcat -v color --pid="$(adb shell pidof -s "$appId")"; }

function adbanim() {
    local factor=${1:-1}
    adb shell settings put global window_animation_scale "$factor"
    adb shell settings put global transition_animation_scale "$factor"
    adb shell settings put global animator_duration_scale "$factor"
}

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
        *)
            unset _adb_type
            echo "adb type: Normal"
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
        *)
            "$ANDROID_HOME/platform-tools/adb" "$@"
            ;;
    esac
}

function adb_all() {
    local org_adb="$ANDROID_HOME/platform-tools/adb"
    local ds=()
    while IFS='' read -r line; do ds+=("$line"); done < <($org_adb devices | awk 'NR > 1 {print $1 }')
    for i in "${ds[@]}"; do
        [[ -n $i ]] && $org_adb -s "$i" "$@"
    done
}

function adbshot() {
    DATE=$(date '+%y%m%d%H%M%S')
    FILE_NAME=screenshot-${DATE}.png
    DIR_PATH=~/Desktop

    adb shell screencap -p /sdcard/screen.png
    adb pull /sdcard/screen.png "${DIR_PATH}/${FILE_NAME}"
    adb shell rm /sdcard/screen.png
    copyfile "${DIR_PATH}/${FILE_NAME}"
}

function adbrecord() {
    DATE=$(date '+%y%m%d%H%M%S')
    FILE_NAME=record-${DATE}
    YOUR_PATH=~/Desktop

    adb shell screenrecord /sdcard/"$FILE_NAME".mp4 &
    pid=$(ps x | grep -v grep | grep "adb shell screenrecord" | awk '{ print $1 }')

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
        alive=$(adb shell ps | grep screenrecord | grep -v grep | awk '{ print $9 }')
        if [ -z "$alive" ]; then
            break
        fi
    done

    printf "Finished the recording process : %s\nSending to %s...\n" "$pid" "$YOUR_PATH"
    adb pull /sdcard/"${FILE_NAME}".mp4 $YOUR_PATH
    adb shell rm /sdcard/"${FILE_NAME}".mp4

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
