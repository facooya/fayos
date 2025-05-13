# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make directory

# FIXME not dir, already exist

# DATA
.section .data

.name_dot: .ascii "."
.name_dotdot: .ascii ".."

.section .text
.code16

.global cmd_mkdir

# ENTRY
# cmd_mkdir()
cmd_mkdir:
  # prol
  push %si

  call outnl

  # add inode
  mov $0x40, %ch
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
  mov $0x40, %ch
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

  # add dentry dot
  mov $.name_dot, %si
  mov $0x01, %cl # name len
  mov $0x40, %ch
  push %si
  push %cx
  mov (next_i_num), %ax
  push %ax
  mov (next_i_num+0x02), %ax
  push %ax
  mov (next_i_num), %ax
  push %ax
  mov (next_i_num+0x02), %ax
  push %ax
  call add_dentry
  add $0x0C, %sp

  # add dentry dotdot
  mov $.name_dotdot, %si
  mov $0x02, %cl # name len
  mov $0x40, %ch
  push %si
  push %cx
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  mov (next_i_num), %ax
  push %ax
  mov (next_i_num+0x02), %ax
  push %ax
  call add_dentry
  add $0x0C, %sp

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
