# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

# NOTE
# [n_add_dentry]
# add_dentry(
#   src_i_num_hi, src_i_num_lo,
#   dst_i_num_hi, dst_i_num_lo,
#   info,
#   name
# )
# [4-byte] *_i_num
#   [2-byte] _hi
#   [2-byte] _lo
# [2-byte] info: hi=file_type, lo=name_len
#   [1-byte] file_type
#   [1-byte] name_len
# [2-byte] name: name ptr

.include "fayfs/sb.s"
.include "fayfs/de.s"

# TEXT
.section .text
.code16

# .global write_dentry2
.global set_blk_lba
.global add_dentry

# ENTRY
# [n_add_dentry]
# add_dentry(
#   src_i_num_hi, src_i_num_lo,
#   dst_i_num_hi, dst_i_num_lo,
#   info,
#   name
# )
add_dentry:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %bx

  # get blk
  mov 0x06(%bp), %ax # src_lo
  push %ax
  mov 0x04(%bp), %ax # src_hi
  push %ax
  call get_i_blk
  add $0x04, %sp

  # read blk
  call set_blk_lba
  call read_block
  mov $0x8000, %bx

  # alloc
  call alloc_dentry
  mov (dentry_ptr), %ax
  add %ax, %bx

  # write i_num
  mov 0x08(%bp), %ax # dst_hi
  mov %ax, DE_I_NUM_HI_OFF(%bx)
  mov 0x0A(%bp), %ax # dst_lo
  mov %ax, DE_I_NUM_LO_OFF(%bx)

  # write info
  mov 0x0C(%bp), %dx
  # dh = file_type
  # dl = name_len
  mov %dh, DE_FILE_TYPE_OFF(%bx)
  mov %dl, DE_NAME_LEN_OFF(%bx)

  # write rec_len
  xor %cx, %cx
  mov %dl, %cl
  add $0x0B, %cx # fix (8), align 4 (3)
  and $0xFFFC, %cx # mask: 0b1100
  mov %cx, DE_REC_LEN_OFF(%bx)

  # ret dentry_ptr
  mov (dentry_ptr), %ax
  add %cx, %ax
  mov %ax, (dentry_ptr)

  # dst name
  mov %bx, %di
  add $DE_NAME_OFF, %di

  # src name
  mov 0x0E(%bp), %si

.add_dentry__set_name:
  # cond: 0 ? set_name_end
  test %dl, %dl
  jz .add_dentry__set_name_end

  # cpy
  mov (%si), %al
  mov %al, (%di)

  # step
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %dl
  jmp .add_dentry__set_name

.add_dentry__set_name_end:
  # write blk
  call write_block

  # epil
  pop %bx
  pop %di
  pop %si
  pop %bp
  ret

# ENTRY
# set_blk_lba() !!! FIXME blk overflow
#   pre: i_blk
set_blk_lba:
  # init
  mov (i_blk), %ax
  mov $0x08, %cx

  # calc
  mul %cx

  mov $FST_LBA_LO, %cx
  add %cx, %ax

  # set dap lba # !!! TMP low high
  push %ax # low
  xor %ax, %ax
  push %ax # high
  call set_dap_lba
  add $0x04, %sp

  # ret
  ret
