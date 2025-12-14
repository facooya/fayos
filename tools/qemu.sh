#!/bin/sh
qemu-system-i386 -drive file=./build/fayos.img,format=raw -rtc base=localtime
