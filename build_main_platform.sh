#!/bin/bash

# if not set library main platform
if [ -z $LIB_MAIN_PLATFORMS ]; then
export LIB_MAIN_PLATFORMS='uno|atmega1280|atmega2560'
fi

lib_main_platforms=$LIB_MAIN_PLATFORMS

while [ $lib_main_platforms -eq 0 ]; do
	main_platform=${lib_main_platforms##*/}
done
