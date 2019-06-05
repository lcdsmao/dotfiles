#!/bin/sh

DATE=`date '+%y%m%d%H%M%S'`
FILE_NAME=screenshot-${DATE}.png
DIR_PATH=~/Desktop

adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png ${DIR_PATH}/${FILE_NAME}
adb shell rm /sdcard/screen.png
~/.oh-my-zsh/custom/file-to-clipboard ${DIR_PATH}/${FILE_NAME}
