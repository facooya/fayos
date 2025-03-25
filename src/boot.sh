#!/bin/sh
set -e
as --32 boot.s -o boot.o
ld --oformat binary -m elf_i386 -Ttext 0x7C00 boot.o -o boot.bin
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
