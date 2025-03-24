#!/bin/sh
# $1 = File Name
# $2 = 0 (0x7C00 AND count=1) OR 1 (0x1000 AND seek=32)
if [ -z "$2" ] || [ "$2" = "0" ]; then
  MEM_ADDR="0x7C00"
  DISK_VALUE="count=1"
elif [ "$2" = "1" ]; then
  MEM_ADDR="0x1000"
  DISK_VALUE="seek=32" # LBA: 0x20
else
  echo "Error"
  exit 1
fi
set -e
as --32 "$1".s -o "$1".o
ld --oformat binary -m elf_i386 -Ttext "$MEM_ADDR" "$1".o -o "$1".bin
dd if="$1".bin of=boot.img bs=512 "$DISK_VALUE" conv=notrunc
