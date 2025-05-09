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

# OFF
.equ SB_MAGIC_LO_OFF, 0x00
.equ SB_MAGIC_HI_OFF, 0x02

# VALUE
.equ SB_LBA_LO, 0x02
.equ SB_LBA_HI, 0x00

# TEXT
.section .text
.code16

.global chk_sb_magic
# .global init_sb

# ENTRY
# chk_sb_magic()
chk_sb_magic:
  push %bx
  call set_sb_lba

  call read_block
  mov $0x8000, %bx

  mov SB_MAGIC_LO_OFF(%bx), %ax
  cmp $0xFAC0, %ax
  jne .chk_sb_magic__ne

  mov SB_MAGIC_HI_OFF(%bx), %ax
  cmp $0xC0DE, %ax
  jne .chk_sb_magic__ne

.chk_sb_magic__ne:
  call init_write_sb
  call write_block
  
.chk_sb_magic__done:
  call reset_dap_target
  pop %bx
  ret

# ENTRY
# init_write_sb()
init_write_sb:
  # prol
  push %bx

  # # set lba
  # call set_sb_lba

  # # read block
  # call read_block

  # # init
  # mov $0x8000, %bx

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
  # call write_block

  # call reset_dap_target

  # epil
  pop %bx
  ret

# ENTRY
# set_sb_lba()
set_sb_lba:
  # set target
  push $0x8000
  push $0x00
  push $0x02
  call set_dap_target
  add $0x06, %sp

  # set lba
  push $SB_LBA_LO
  push $SB_LBA_HI
  call set_dap_lba
  add $0x04, %sp
  ret
