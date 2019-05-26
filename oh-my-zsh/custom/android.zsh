export appId='<Replace with ApplicationId like com.abc.def>'
export mainActivityName='<Replace with MainActivity of your app like com.abc.def.MainActivity>'
export buildVariantTarget='iD'  # Default to installDebug (iD) ; Replace it with your default buildVariantType
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools:$HOME/Library/Android/sdk/tools
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home

alias gn='./gradlew'
alias latestapkname='ls -tr | grep '.apk' | tail -1 | pbcopy'  # copy latestApk file name in current folder to clipboard.
alias adbca="adb shell dumpsys window windows | grep -E 'mCurrentFocus'" # show current activity name
alias adbrecord="$HOME/.oh-my-zsh/custom/adb-record.sh"

function sta() { adb shell am start -n "$appId"/"$mainActivityName";}  # start app
function stp() { adb shell am force-stop "$appId";} # force stop app
function clr() { adb shell pm clear "$appId";}  # clear data of app
function uns() { adb uninstall "$appId";}   # uninstall app

function bld() { if [ "$1" == "c" ];then gn clean ;fi; gn "$buildVariantTarget" ; sta ;}  # Build with buildVariantTarget flavor then install App  then start it
function bldu() { uns; gn "$buildVariantTarget"; sta; }  # Uninstall App then Build with buildVariantTarget flavor then install App & then start it

function updateappid() { if [ -z != $1 ];then appId="$1";fi; }    # use updateAppId com.random.otherapp to change it for that tab.
function updatemainactivity() { if [ -z != $1 ];then mainActivityName="$1";fi; }
function updatebuildtype() { if [ -z != $1 ];then buildVariantTarget="$1";fi; }
function printvariables() { echo "appId = $appId
mainActivityName = $mainActivityName 
buildVariantTarget = $buildVariantTarget"; }

alias ins='uns && adb install '   # Uninstall App then install with existing app path ;    ins <pathToApk.apk>
alias upg='adb install -r '
function upglatest() { latestapkname; upg $(pbpaste); sta; }  # Upgrade app with latest updated apk in current folder
function atest() { gn test connectedAndroidTest; } # execute all tests

alias gitrev='git reset --soft HEAD^'  # revert your last commit from your branch
alias gitcurrent='git rev-parse --abbrev-ref HEAD | pbcopy'  # copy current branch name to clipboard , useful when giving PR's
alias gitdelbranch='git branch | grep "<branchpattern>" | xargs git branch -D' # deletes git local branches matching pattern, to reduce clutter of branches.

alias logs='adb logcat AndroidRuntime:E *:S'   # prints only Crash logs, if AndroidStudio is not working use this command.
alias text='adb shell input text '   # to enter text input to your device

function ktg() { git diff --name-only --cached --relative | grep '\.kt[s"]\?$' | xargs ktlint --relative . } # check lint of modified/new kotlin files
