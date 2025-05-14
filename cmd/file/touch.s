# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Create file

.section .text
.code16

.global cmd_touch

# FIXME already exist

# ENTRY
# cmd_touch()
cmd_touch:
  # prol
  push %si

  call outnl

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

  # update i file_size
  mov (dentry_ptr), %ax
  push %ax
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call update_i_file_size
  add $0x06, %sp

  # update sb
  mov (next_i_num), %ax
  add $0x01, %ax
  mov %ax, (next_i_num)
  mov (next_i_blk), %ax
  add $0x01, %ax
  mov %ax, (next_i_blk)
  call write_sb

  # epil
  pop %si
  ret
