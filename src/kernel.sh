#!/bin/sh
set -e
as --32 kernel.s -o kernel.o
as --32 ./inc/lib/print.s -o print.o

ld -m elf_i386 -T linker.ld kernel.o print.o -o kernel.bin
dd if=kernel.bin of=boot.img bs=512 seek=32 conv=notrunc
