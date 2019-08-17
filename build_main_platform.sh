#!/bin/bash

# define colors
GRAY='\033[1;30m'; RED='\033[0;31m'; LRED='\033[1;31m'; GREEN='\033[0;32m'; LGREEN='\033[1;32m'; ORANGE='\033[0;33m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; LBLUE='\033[1;34m'; PURPLE='\033[0;35m'; LPURPLE='\033[1;35m'; CYAN='\033[0;36m'; LCYAN='\033[1;36m'; LGRAY='\033[0;37m'; WHITE='\033[1;37m';
DEFAULT='\e[0m';
exit_code=0
# if not set library main platform
if [ -z $LIB_MAIN_PLATFORMS ]; then
export LIB_MAIN_PLATFORMS="uno|mega1280|mega2560|esp32|esp8266"
fi

lib_main_platforms=$LIB_MAIN_PLATFORMS
file_path=$(cd `dirname $0`;pwd)
# echo $file_path
# echo $PWD
# echo $lib_main_platforms
# echo ${lib_main_platforms##*|}
# echo ${lib_main_platforms%|*}

result_msg=""

while [ "$lib_main_platforms" != "" ]; do
	if [ `expr index "$lib_main_platforms" "|"` != "0" ]; then
		main_platform=${lib_main_platforms##*|}
		lib_main_platforms=${lib_main_platforms%|*}
	else
		main_platform=$lib_main_platforms
		lib_main_platforms=""
	fi
	bash $file_path/arduino_lib_auto_test.sh $main_platform
	status=$?
	result_msg=$result_msg$main_platform
	if [ $status -ne 0 ]; then
		exit_code=1
		result_msg="$result_msg$RED ✘$DEFAULT\n"
	else
		result_msg="$result_msg$GREEN ✓$DEFAULT\n"
	fi
	# echo $main_platform
	# echo $lib_main_platforms
done

echo "***************************************"
echo "***************************************"
echo -e $result_msg

if [ $exit_code -gt 0 ]; then
	echo -e "Compile result:$RED FAIL $DEFAULT"
	exit 1
else
	echo -e "Compile result:$GREEN SUCCESS $DEFAULT"
	exit 0
fi
