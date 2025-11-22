#!/bin/sh
qemu-system-x86_64 -drive format=raw,file=./build/fayos.img -rtc base=localtime
