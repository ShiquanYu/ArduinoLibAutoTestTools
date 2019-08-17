#!/bin/bash

# define colors
GRAY='\033[1;30m'; RED='\033[0;31m'; LRED='\033[1;31m'; GREEN='\033[0;32m'; LGREEN='\033[1;32m'; ORANGE='\033[0;33m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; LBLUE='\033[1;34m'; PURPLE='\033[0;35m'; LPURPLE='\033[1;35m'; CYAN='\033[0;36m'; LCYAN='\033[1;36m'; LGRAY='\033[0;37m'; WHITE='\033[1;37m';
DEFAULT='\e[0m'
exit_code=0

export MAIN_PLATFORMS='declare -A main_platforms=( [uno]="arduino:avr:uno" [due]="arduino:sam:arduino_due_x" [zero]="arduino:samd:arduino_zero_native" [esp8266]="esp8266:esp8266:huzzah:eesz=4M3M,xtal=80" [leonardo]="arduino:avr:leonardo" [m4]="adafruit:samd:adafruit_metro_m4:speed=120" [mega1280]="arduino:avr:mega:cpu=atmega1280" [mega2560]="arduino:avr:mega:cpu=atmega2560" [esp32]="esp32:esp32:featheresp32:FlashFreq=80" )'
eval $MAIN_PLATFORMS
platform_key=$1
platform=${main_platforms[$platform_key]}
# echo -e $platform

# grab all pde and ino example sketches
declare -a examples

examples=($(find $PWD -name "*.pde" -o -name "*.ino"))

# last="${examples[@]:(-1)}"

# for f in "${examples[@]}"; do
# 	echo ${f##*/}
# done
# echo $last
# for i in $COLUMNS; do
# 	echo '#'
# done
echo -e "Compile library: "$YELLOW${PWD##*/}$DEFAULT

title="Switch to ${platform##*=}  "
# show title like"##########title##########"
title_len=$(expr length "$title")
hash_num=$(((COLUMNS-title_len)/2))
if [ $hash_num -gt 40 ]; then
	hash_num=40
fi
hash_str=""
for i in $(seq 1 $hash_num); do
	hash_str=$hash_str"#"
done
# echo -e $hash_str$title$hash_str
echo -n $title

platform_stdout=$(arduino --board $platform --save-prefs 2>&1)
platform_switch=$?
if [ $platform_switch -ne 0 ]; then
# heavy X
echo -e """$RED""✖"$DEFAULT
echo -e "arduino --board ${platform} --save-prefs 2>&1"
echo "$platform_stdout"
exit_code=1
exit 1
else
# heavy checkmark
echo -e """$GREEN""✓"$DEFAULT
fi

# echo "$platform_stdout"
for example in "${examples[@]}"; do
	build_stdout=$(arduino --verify $example 2>&1)
	if [ $? -eq 0 ]; then
		echo -e ${example##*/} $GREEN"\xe2\x9c\x93"$DEFAULT		#✓ ✘
	else
		exit_code=1
		echo -e "$RED=====================ERROR=====================$DEFAULT"
		echo -e "in file: $WHITE${example##*/}$DEFAULT"
		echo -e "$build_stdout"
		echo -e "$RED===============================================$DEFAULT"
	fi
done
if [ $exit_code -gt 0 ]; then
	echo -e "Compile result:$RED FAIL $DEFAULT"
	exit 1
else
	echo -e "Compile result:$GREEN SUCCESS $DEFAULT"
	exit 0
fi


