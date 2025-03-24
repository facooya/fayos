#!/bin/sh
set -e # Error Exit
dd if=/dev/zero of=boot.img bs=512 count=2880 # Init boot.img (512 * 2880 Test size)
./push.sh boot 0 # Compile and push boot.img
./push.sh kernel 1 # Compile and push boot.img
