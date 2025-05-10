# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Change directory 2 for fayfs 2, Temporary command

.section .text
.code16

.global cmd_cd2

# !!! TMP read_inode => read_block => cmp_dentry => 
#   cmp_file_type => update_inode_number

# ENTRY
# cmd_cd2()
cmd_cd2:
  push %si
  push %bx

  call outnl

  call read_inode

  call set_blk_lba

  # read block
  call read_block
  mov $0x8000, %bx

  mov (arg_ptr), %si

.cmd_cd2__chk_name:

.cmd_cd2__done:
  # epil
  pop %si
  pop %bx
  ret
