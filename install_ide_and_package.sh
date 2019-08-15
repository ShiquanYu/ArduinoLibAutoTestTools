#!/bin/bash

# define colors
GRAY='\033[1;30m'; RED='\033[0;31m'; LRED='\033[1;31m'; GREEN='\033[0;32m'; LGREEN='\033[1;32m'; ORANGE='\033[0;33m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; LBLUE='\033[1;34m'; PURPLE='\033[0;35m'; LPURPLE='\033[1;35m'; CYAN='\033[0;36m'; LCYAN='\033[1;36m'; LGRAY='\033[0;37m'; WHITE='\033[1;37m';
DEFAULT='\e[0m';

# echo -e "\n########################################################################";
# echo -e "${YELLOW}INSTALLING ARDUINO IDE${DEFAULT}"
# echo "########################################################################";

# # if .travis.yml does not set version
# if [ -z $ARDUINO_IDE_VERSION ]; then
# export ARDUINO_IDE_VERSION="1.8.9"
# echo "NOTE: YOUR .TRAVIS.YML DOES NOT SPECIFY ARDUINO IDE VERSION, USING $ARDUINO_IDE_VERSION"
# fi

# # if newer version is requested
# if [ ! -f $HOME/arduino_ide/$ARDUINO_IDE_VERSION ] && [ -f $HOME/arduino_ide/arduino ]; then
# echo -n "DIFFERENT VERSION OF ARDUINO IDE REQUESTED: "
# shopt -s extglob
# cd $HOME/arduino_ide/
# rm -rf *
# if [ $? -ne 0 ]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
# cd $OLDPWD
# fi

# # if not already cached, download and install arduino IDE
# echo -n "ARDUINO IDE STATUS: "
# if [ ! -f $HOME/arduino_ide/arduino ]; then
# echo -n "DOWNLOADING: "
# wget --quiet https://downloads.arduino.cc/arduino-$ARDUINO_IDE_VERSION-linux64.tar.xz
# if [ $? -ne 0 ]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
# echo -n "UNPACKING ARDUINO IDE: "
# [ ! -d $HOME/arduino_ide/ ] && mkdir $HOME/arduino_ide
# tar xf arduino-$ARDUINO_IDE_VERSION-linux64.tar.xz -C $HOME/arduino_ide/ --strip-components=1
# if [ $? -ne 0 ]; then echo -e """$RED""\xe2\x9c\x96"; else echo -e """$GREEN""\xe2\x9c\x93"; fi
# # created a file named with IDE version to mark the IDE version download
# touch $HOME/arduino_ide/$ARDUINO_IDE_VERSION
# else
# echo -n "CACHED: "
# echo -e """$GREEN""\xe2\x9c\x93"
# fi

# # ===============================Download Arduino Finished=====================================

# # link test library folder to the arduino libraries folder
# ln -s $TRAVIS_BUILD_DIR $HOME/arduino_ide/libraries/Adafruit_Test_Library

# # add the arduino CLI to our PATH
# export PATH="$HOME/arduino_ide:$PATH"

echo -e "\n########################################################################";
echo -e "${YELLOW}INSTALLING DEPENDENCIES$DEFAULT"
echo "########################################################################";

export MAIN_PACKAGES='declare -A main_packages=( [esp8266]="http://arduino.esp8266.com/stable/package_esp8266com_index.json" [esp32]="https://dl.espressif.com/dl/package_esp32_index.json" )'
export MAIN_BOARDS='declare -A main_boards=( [esp8266]="esp8266:esp8266" [esp32]="esp32:esp32" )'
eval $MAIN_PACKAGES
eval $MAIN_BOARDS
package_len=$#

echo $package_len

packages_index=""
for i in $*; do
    package_index=${main_packages[$i]}
    if [ ! $package_index ]; then 
    echo -e "${RED}NOT AVAILABLE PACKAGE: $i${DEFAULT}" 
    continue 
    fi
    packages_index="$packages_index$package_index,"
done

# add index
echo -n "ADD PACKAGE INDEX: $packages_index "
# DEPENDENCY_OUTPUT=$(arduino --pref "boardsmanager.additional.urls=https://adafruit.github.io/arduino-board-index/package_adafruit_index.json,http://arduino.esp8266.com/stable/package_esp8266com_index.json,https://dl.espressif.com/dl/package_esp32_index.json" --save-prefs 2>&1)
DEPENDENCY_OUTPUT=$(arduino --pref "boardsmanager.additional.urls=$packages_index" --save-prefs 2>&1)
# arduino --pref "boardsmanager.additional.urls=$packages_index" --save-prefs
if [ $? -ne 0 ]; then echo -e """$RED""\xe2\x9c\x96"$DEFAULT; else echo -e """$GREEN""\xe2\x9c\x93"$DEFAULT; fi

# This is a hack, we have to install by hand so lets delete it
echo "Removing ESP32 cache"
rm -rf ~/.arduino15/packages/esp32
echo "Current packages list:"
ls ~/.arduino15/packages/

for i in $*; do
    package=${main_boards[$i]}
    if [ ! $package ]; then 
    echo -e "${RED}NOT AVAILABLE PACKAGE: $i${DEFAULT}" 
    continue 
    fi

    # download
    echo -n "DOWNLOAD PACKAGE: $i "
    DEPENDENCY_OUTPUT=$(arduino --install-boards $package 2>&1)
    # arduino --install-boards $package
    if [ $? -ne 0 ]; then echo -e "\xe2\x9c\x96 OR CACHED\n$DEFAULT$DEPENDENCY_OUTPUT"; else echo -e """$GREEN""\xe2\x9c\x93$DEFAULT"; fi
done
# echo -n "ESP32: "
# # DEPENDENCY_OUTPUT=$(arduino --install-boards esp32:esp32 2>&1)
# arduino --install-boards esp32:esp32
# if [ $? -ne 0 ]; then echo -e "\xe2\x9c\x96 OR CACHED"; else echo -e """$GREEN""\xe2\x9c\x93"; fi

# echo "$DEPENDENCY_OUTPUT"

exit 0
