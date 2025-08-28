#!/bin/sh
qemu-system-x86_64 -M pc -drive format=raw,file=./build/fayos.img
