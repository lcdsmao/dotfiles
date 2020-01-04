export appId='<Replace with ApplicationId like com.abc.def>'
export mainActivityName='<Replace with MainActivity of your app like com.abc.def.MainActivity>'
export buildVariantTarget='iD' # Default to installDebug (iD) ; Replace it with your default buildVariantType
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK=$ANDROID_HOME
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/tools
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
alias gn='./gradlew'
alias latestapkname='ls -tr | grep '.apk' | tail -1 | pbcopy'            # copy latestApk file name in current folder to clipboard.
alias adbca="adb shell dumpsys window windows | grep -E 'mCurrentFocus'" # show current activity name
alias adbrecord='$HOME/.oh-my-zsh/custom/adb-record.sh'
alias adbshot='$HOME/.oh-my-zsh/custom/adb-screenshot.sh'

function sta() { adb shell am start -n "$appId"/"$mainActivityName"; } # start app
function stp() { adb shell am force-stop "$appId"; }                   # force stop app
function clr() { adb shell pm clear "$appId"; }                        # clear data of app
function uns() { adb uninstall "$appId"; }                             # uninstall app
function iturl() { adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "$1"; }

# Build with buildVariantTarget flavor then install App  then start it
function bld() {
    if [[ "$1" == "c" ]]; then
        gn clean
    fi
    gn "$buildVariantTarget" && sta
}

# Uninstall App then Build with buildVariantTarget flavor then install App & then start it
function bldu() {
    uns && gn "$buildVariantTarget" && sta
}

# use updateAppId com.random.otherapp to change it for that tab.
function updateappid() {
    if [[ -n "$1" ]]; then
        appId="$1"
    fi
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

alias logs='adb logcat AndroidRuntime:E *:S' # prints only Crash logs, if AndroidStudio is not working use this command.
alias text='adb shell input text '           # to enter text input to your device
alias adblog='adb logcat -v color'
function adbloge() { adblog | grep "$@"; }

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
            ;;
        -f)
            export _adb_type="FZF"
            ;;
        *)
            unset _adb_type
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
    while IFS='' read -r line; do array+=("$line"); done < <($org_adb devices | awk 'NR > 1 {print $1 }')
    for i in "${ds[@]}"; do
        $org_adb -s "$i" "$@"
    done
}
