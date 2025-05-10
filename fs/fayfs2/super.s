# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Super block, LBA [2-3]

.include "sb.s"

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

# TEXT
.section .text
.code16

.global chk_sb_magic

# ENTRY
read_sb:
  ret

# ENTRY
write_sb:
  ret

# ENTRY
# chk_sb_magic()
chk_sb_magic:
  # prol
  push %bx

  # set lba
  call set_sb_lba

  # read
  call read_block
  mov $0x8000, %bx

  # cond: != ? ne
  mov SB_MAG_LO_OFF(%bx), %ax
  cmp $SB_MAG_LO, %ax
  jne .chk_sb_magic__ne

  # cond: != ? ne
  mov SB_MAG_HI_OFF(%bx), %ax
  cmp $SB_MAG_HI, %ax
  jne .chk_sb_magic__ne

  # jump
  jmp .chk_sb_magic__done

.chk_sb_magic__ne:
  call init_write_sb
  call write_block
  
.chk_sb_magic__done:
  call reset_dap_target

  # epil
  pop %bx
  ret

# ENTRY
# init_write_sb()
init_write_sb:
  # magic
  mov $SB_MAG_LO, %ax
  mov %ax, SB_MAG_LO_OFF(%bx)
  mov $SB_MAG_HI, %ax
  mov %ax, SB_MAG_HI_OFF(%bx)

  # sb lba
  mov $SB_LBA_LO, %ax
  mov %ax, SB_LBA_LO_OFF(%bx)
  mov $SB_LBA_HI, %ax
  mov %ax, SB_LBA_HI_OFF(%bx)

  # i lba
  mov $SB_I_LBA_LO, %ax
  mov %ax, SB_I_LBA_LO_OFF(%bx)
  mov $SB_I_LBA_HI, %ax
  mov %ax, SB_I_LBA_HI_OFF(%bx)

  # root i num
  mov $SB_ROOT_I_NUM_LO, %ax
  mov %ax, SB_ROOT_I_NUM_LO_OFF(%bx)
  mov $SB_ROOT_I_NUM_HI, %ax
  mov %ax, SB_ROOT_I_NUM_HI_OFF(%bx)

  # fst lba
  mov $SB_FST_LBA_LO, %ax
  mov %ax, SB_FST_LBA_LO_OFF(%bx)
  mov $SB_FST_LBA_HI, %ax
  mov %ax, SB_FST_LBA_HI_OFF(%bx)

  # fst i num
  mov $SB_FST_I_NUM_LO, %ax
  mov %ax, SB_FST_I_NUM_LO_OFF(%bx)
  mov $SB_FST_I_NUM_HI, %ax
  mov %ax, SB_FST_I_NUM_HI_OFF(%bx)

  # fst i blk
  mov $SB_FST_I_BLK_LO, %ax
  mov %ax, SB_FST_I_BLK_LO_OFF(%bx)
  mov $SB_FST_I_BLK_HI, %ax
  mov %ax, SB_FST_I_BLK_HI_OFF(%bx)

  # i size
  mov $SB_I_SIZE, %ax
  mov %ax, SB_I_SIZE_OFF(%bx)

  # next i num
  mov $SB_NEXT_I_NUM_LO, %ax
  mov %ax, SB_NEXT_I_NUM_LO_OFF(%bx)
  mov $SB_NEXT_I_NUM_HI, %ax
  mov %ax, SB_NEXT_I_NUM_HI_OFF(%bx)

  # next blk num
  mov $SB_NEXT_I_BLK_LO, %ax
  mov %ax, SB_NEXT_I_BLK_LO_OFF(%bx)
  mov $SB_NEXT_I_BLK_HI, %ax
  mov %ax, SB_NEXT_I_BLK_HI_OFF(%bx)
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
