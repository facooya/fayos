# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Touch 2 for fayfs 2, Temporary command

.section .text
.code16

.global cmd_touch2

# ENTRY
# cmd_touch2()
cmd_touch2:
  push %bx

  call outnl

  call write_inode

  call set_blk_lba
  call read_block
  mov $0x8000, %bx

  call alloc_dentry
  call write_dentry2 # !!! TMP
  call write_block

  pop %bx
  ret
