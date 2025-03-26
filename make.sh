#!/bin/sh
set -e # Error Exit
dd if=/dev/zero of=./build/boot.img bs=512 count=2880 # Init boot.img (512 * 2880 Test size)
./boot.sh
./kernel.sh
