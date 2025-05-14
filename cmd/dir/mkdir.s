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
  push %bx

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

  # update child i_file_size
  mov (dentry_ptr), %ax # HACK!!! dentry_ptr
  push %ax
  mov (next_i_num), %ax
  push %ax
  mov (next_i_num+0x02), %ax
  push %ax
  call update_i_file_size
  add $0x06, %sp

  # read_inode(i_num_hi, i_num_lo)
  #   ret: i_file_size
  #   ret: i_blk
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call read_inode
  add $0x04, %sp

  # read
  call set_blk_lba
  call read_block
  mov $0x8000, %bx
  call alloc_dentry

  # update i file_size # HACK!!! dentry_ptr
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
  pop %bx
  pop %si
  ret
