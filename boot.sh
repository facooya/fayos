#!/bin/sh
set -e
as --32 ./boot/boot.s -o ./build/boot.o
ld --oformat binary -m elf_i386 -Ttext 0x7C00 ./build/boot.o -o ./build/boot.bin
dd if=./build/boot.bin of=./build/boot.img bs=512 count=1 conv=notrunc
