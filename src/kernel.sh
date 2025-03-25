#!/bin/sh
set -e
as --32 kernel.s -o kernel.o
as --32 ./inc/lib/print.s -o ./inc/lib/print.o

as --32 ./inc/sys/kbd.s -o ./inc/sys/kbd.o
as --32 ./inc/sys/disk.s -o ./inc/sys/disk.o
as --32 ./inc/sys/err.s -o ./inc/sys/err.o

as --32 ./inc/cmd/cmd_exec.s -o ./inc/cmd/cmd_exec.o
as --32 ./inc/cmd/cli_tok.s -o ./inc/cmd/cli_tok.o
as --32 ./inc/cmd/cli_buf.s -o ./inc/cmd/cli_buf.o

ld -m elf_i386 -T linker.ld kernel.o \
  ./inc/lib/print.o \
  ./inc/sys/kbd.o \
  ./inc/sys/disk.o \
  ./inc/sys/err.o \
  ./inc/cmd/cmd_exec.o \
  ./inc/cmd/cli_tok.o \
  ./inc/cmd/cli_buf.o \
  -o kernel.bin

dd if=kernel.bin of=boot.img bs=512 seek=32 conv=notrunc
