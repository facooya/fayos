# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Index node

# NOTE

.include "fayfs/sb.s"
.include "fayfs/i.s"

# TEXT
.section .text
.code16

.global read_inode
.global write_inode
.global init_inode

.global set_i_lba
.global get_i_blk
.global add_inode

# ENTRY
# [n_add_inode]
# add_inode(
#   i_num_hi, i_num_lo
#   i_blk_num_hi, i_blk_num_lo
#   info (hi=file_type, lo=blk_len),
#   # !!! FIXME blk_arr, blk_len
# )
add_inode:
  # prol
  push %bp
  mov %sp, %bp
  push %bx

  # read i tbl
  call set_i_lba
  call read_block
  mov $0x8000, %bx

  # calc inode !!! FIXME hi,lo
  xor %dx, %dx
  mov 0x06(%bp), %cx
  mov $I_SIZE, %ax
  mul %cx
  # ax *= cx

  # set mem
  add %ax, %bx

  # write i_blk !!! FIXME hi,lo
  mov 0x0A(%bp), %ax
  mov %ax, I_BLK_LO_OFF(%bx)

  # write info
  mov 0x0C(%bp), %ax
  mov %ah, I_FILE_TYPE_OFF(%bx)
  mov %al, I_BLK_LEN_OFF(%bx)

  # add next !!! TMP
  mov (next_i_num), %ax
  add $0x01, %ax
  mov %ax, (next_i_num)
  mov (next_i_blk), %ax
  add $0x01, %ax
  mov %ax, (next_i_blk)

  # write
  call write_block

  # epil
  pop %bx
  pop %bp
  ret

# ENTRY
# get_i_blk(i_num_hi, i_num_lo)
#   ret: i_blk
get_i_blk:
  # prol
  push %bp
  mov %sp, %bp
  push %bx

  # read inode
  call set_i_lba
  call read_block
  mov $0x8000, %bx

  # calc i_num
  xor %dx, %dx
  mov 0x04(%bp), %cx
  mov $I_SIZE, %ax
  mul %cx
  # ax *= cx

  # set mem
  add %ax, %bx

  # set i_blk
  mov I_BLK_LO_OFF(%bx), %ax
  mov %ax, (i_blk) # TMP
  mov I_BLK_HI_OFF(%bx), %dx
  mov %dx, (i_blk+0x02) # TMP

  # epil
  pop %bx
  pop %bp
  ret

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
  mov I_BLK_LO_OFF(%bx), %ax
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

  # block num
  mov (next_i_blk), %ax
  mov %ax, I_BLK_LO_OFF(%bx)

  # set next blk_num
  add $0x01, %ax
  mov %ax, (next_i_blk)

  # file type !!! FIXME 4(%bp)
  mov $0x80, %al
  mov %al, I_FILE_TYPE_OFF(%bx)

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
