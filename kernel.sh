#!/bin/sh
set -e
as --32 ./kernel/kernel.s -o ./build/kernel.o
as --32 ./lib/print.s -o ./build/print.o
as --32 ./lib/err.s -o ./build/err.o

as --32 ./drivers/kbd.s -o ./build/kbd.o
as --32 ./drivers/disk.s -o ./build/disk.o

as --32 ./cmd/cmd_exec.s -o ./build/cmd_exec.o
as --32 ./cmd/cli_tok.s -o ./build/cli_tok.o
as --32 ./cmd/cli_buf.s -o ./build/cli_buf.o

ld -m elf_i386 -T ./build/linker.ld ./build/kernel.o \
  ./build/print.o \
  ./build/kbd.o \
  ./build/disk.o \
  ./build/err.o \
  ./build/cmd_exec.o \
  ./build/cli_tok.o \
  ./build/cli_buf.o \
  -o ./build/kernel.bin

dd if=./build/kernel.bin of=./build/boot.img bs=512 seek=32 conv=notrunc
