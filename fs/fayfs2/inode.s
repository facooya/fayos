# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Index node

.include "fayfs/sb.s"

# TEXT
.section .text
.code16

.global read_inode
.global write_inode
.global init_inode
.global set_i_lba

# ENTRY
# read_inode()
read_inode:
  # prol
  push %bx

  # set lba
  call set_i_lba

  # read block
  call read_block
  mov $0x8000, %bx

  # calc i_num
  xor %dx, %dx
  mov (i_num), %cx
  mov $I_SIZE, %ax
  mul %cx
  # ax *= cx

  # set mem
  add %ax, %bx

  # set i_blk
  mov (%bx), %ax
  mov %ax, (i_blk)

  # epil
  pop %bx
  ret

# ENTRY
# write_inode() !!! TMP low high
write_inode:
  # prol
  push %bx

  # set lba
  call set_i_lba

  # read block
  call read_block
  mov $0x8000, %bx

  # calc tbl ptr !!! FIXME i_num
  xor %dx, %dx
  mov (next_i_num), %cx
  mov $I_SIZE, %ax
  mul %cx
  # ax *= cx

  # add tbl ptr
  add %ax, %bx

  # set next i_num
  add $0x01, %cx
  mov %cx, (next_i_num)

  # block num # !!! FIXME i_blk
  mov (next_i_blk), %ax
  mov %ax, 0(%bx)

  # set next blk_num
  add $0x01, %ax
  mov %ax, (next_i_blk)

  # file type
  mov $0x80, %al
  mov %al, 0x1C(%bx)
  
  # write block
  call write_block

  # epil
  pop %bx
  ret

# ENTRY
# init_inode()
init_inode:
  # root dir
  call write_inode
  ret

# ENTRY
# set_i_lba()
set_i_lba:
  # set lba
  push $I_LBA_LO
  push $I_LBA_HI
  call set_dap_lba
  add $0x04, %sp
  ret
