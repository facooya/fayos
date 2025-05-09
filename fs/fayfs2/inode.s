# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Index node

.equ INODE_SIZE, 0x20

# TEXT
.section .text
.code16

.global get_inode
.global set_inode

# ENTRY
# get_inode(i_num) !!! TMP low high
get_inode:
  # prol
  push %bp
  mov %sp, %bp
  push %bx

  # get block
  # set dap lba
  push $0x10
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

  # i_num calc
  mov 4(%bp), %cx
  mov $INODE_SIZE, %ax
  mul %cx
  add %ax, %bx

  # ret: b_num
  mov (%bx), %ax
  mov %ax, (b_num)

  # epil
  pop %bx
  pop %bp
  ret

# ENTRY
# set_inode() !!! TMP low high
set_inode:
  # prol
  push %bx

  # set dap lba
  push $0x10
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

  # calc
  mov (fi_num), %cx
  xor %ax, %ax
  mov $INODE_SIZE, %ax
  mul %cx

  # calc 2
  add %ax, %bx

  # block num
  mov (fb_num), %ax
  mov %ax, 0(%bx)
  add $0x01, %ax
  mov %ax, (fb_num)

  # file type
  mov $0x80, %al
  mov %al, 0x1C(%bx)
  
  # write block
  call write_block

  add $0x01, %cx
  mov %cx, (fi_num)

  # epil
  pop %bx
  ret
