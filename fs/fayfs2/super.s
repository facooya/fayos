# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Super block, LBA [2-3]

.include "fs.s"

.section .data

.global superblock

superblock:
  .long 0x02 # First Inode
  .long 0x01 # First Block
  .long 0x80 # First LBA
  .long 0x10 # Inode Table LBA
  .byte 0x40 # Size Inode
  .zero 0x03 # Padding
  # FST_LBA + (BLOCK * 8) = LBA
  # IN_SIZE + INODE_TABLE

.section .text
.code16

.global init_superblock

init_superblock:
  push %si
  push %bx

  # set dap target
  push $0x8000
  push $0x00
  push $0x02
  call set_dap_target
  add $0x06, %sp

  push $0x02
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # init
  mov $0x8000, %bx
  mov $superblock, %si

  # body
  mov SB_IN_LO(%si), %ax
  mov %ax, SB_IN_LO(%bx)
  mov SB_IN_HI(%si), %ax
  mov %ax, SB_IN_HI(%bx)

  mov SB_BLK_LO(%si), %ax
  mov %ax, SB_BLK_LO(%bx)
  mov SB_BLK_HI(%si), %ax
  mov %ax, SB_BLK_HI(%bx)

  mov SB_LBA_LO(%si), %ax
  mov %ax, SB_LBA_LO(%bx)
  mov SB_LBA_HI(%si), %ax
  mov %ax, SB_LBA_HI(%bx)

  mov SB_IT_LBA_LO(%si), %ax
  mov %ax, SB_IT_LBA_LO(%bx)
  mov SB_IT_LBA_HI(%si), %ax
  mov %ax, SB_IT_LBA_HI(%bx)

  mov SB_IN_SIZE(%si), %al
  mov %al, SB_IN_SIZE(%bx)

  # done
  call write_block
  call reset_dap_target
  push $0x80
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  pop %bx
  pop %si
  ret
