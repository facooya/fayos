# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Super block, LBA [2-3]

.include "fs.s"

.equ MAGIC_NUM_LO, 0xFAC0
.equ MAGIC_NUM_HI, 0xC0DE

.equ FIRST_INODE_LO, 0x02
.equ FIRST_INODE_HI, 0x00

.equ FIRST_BLOCK_LO, 0x01
.equ FIRST_BLOCK_HI, 0x00

.equ FIRST_LBA_LO, 0x80
.equ FIRST_LBA_HI, 0x00

.equ INODE_TABLE_LBA_LO, 0x10
.equ INODE_TABLE_LBA_HI, 0x00

.equ INODE_SIZE, 0x20

.section .text
.code16

.global init_superblock

init_superblock:
  # prol
  push %si
  push %bx

  # set dap target
  push $0x8000
  push $0x00
  push $0x02
  call set_dap_target
  add $0x06, %sp

  # set dap lba
  push $0x02
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block

  # init
  mov $0x8000, %bx

  # body
  mov $MAGIC_NUM_LO, %ax
  mov %ax, SB_MAGIC_LO(%bx)
  mov $MAGIC_NUM_HI, %ax
  mov %ax, SB_MAGIC_HI(%bx)

  mov $FIRST_INODE_LO, %ax
  mov %ax, SB_IN_LO(%bx)
  mov $FIRST_INODE_HI, %ax
  mov %ax, SB_IN_HI(%bx)

  mov $FIRST_BLOCK_LO, %ax
  mov %ax, SB_BLK_LO(%bx)
  mov $FIRST_BLOCK_HI, %ax
  mov %ax, SB_BLK_HI(%bx)

  mov $FIRST_LBA_LO, %ax
  mov %ax, SB_LBA_LO(%bx)
  mov $FIRST_LBA_HI, %ax
  mov %ax, SB_LBA_HI(%bx)

  mov $INODE_TABLE_LBA_LO, %ax
  mov %ax, SB_IT_LBA_LO(%bx)
  mov $INODE_TABLE_LBA_LO, %ax
  mov %ax, SB_IT_LBA_HI(%bx)

  mov $INODE_SIZE, %al
  mov %al, SB_IN_SIZE(%bx)

  # write block
  call write_block

  # reset
  push $0x80
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call reset_dap_target

  # epil
  pop %bx
  pop %si
  ret
