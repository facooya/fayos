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
  # prol
  push %si
  push %bx

  call outnl

  # call write_inode

  # mov $0x80, %ax
  # push %ax
  # call write_dentry2 # !!! TMP
  # add $0x02, %sp

  # add inode
  mov $0x80, %ch
  mov $0x01, %cl
  push %cx
  mov (next_i_blk), %ax
  push %ax
  mov (next_i_blk+0x02), %ax
  push %ax
  mov (next_i_num), %ax
  push %ax
  mov (next_i_num+0x02), %ax
  push %ax
  call add_inode
  add $0x0A, %sp

  # add dentry
  mov (arg_ptr), %si
  push %si
  call strlen
  add $0x02, %sp
  # ax = len
  mov %al, %cl
  mov $0x80, %ch
  push %si
  push %cx
  mov (next_i_num), %ax
  push %ax
  mov (next_i_num+0x02), %ax
  push %ax
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call add_dentry
  add $0x0C, %sp

  # epil
  pop %bx
  pop %si
  ret
