# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

.include "fayfs/sb.s"
.include "fayfs/de.s"

# TEXT
.section .text
.code16

.global write_dentry2
.global set_blk_lba

# ENTRY
# write_dentry2(file_type)
write_dentry2:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %bx

  # read block
  call set_blk_lba
  call read_block
  mov $0x8000, %bx

  # get dentry_ptr
  call alloc_dentry

  # init
  mov (dentry_ptr), %bx

  # body
  mov (next_i_num), %ax
  mov %ax, DE_I_NUM_LO_OFF(%bx)
  mov (next_i_num+2), %ax
  mov %ax, DE_I_NUM_HI_OFF(%bx)

  # get file type
  mov 4(%bp), %ax
  mov %al, DE_FILE_TYPE_OFF(%bx)

  # init
  mov (arg_ptr), %si
  mov %bx, %di
  add $DE_NAME_OFF, %di
  xor %cx, %cx

.write_dentry__set_name:
  # load
  mov (%si), %al

  # cond: null ? set_name_end
  test %al, %al
  jz .write_dentry__set_name_end

  # store
  mov %al, (%di)

  # step
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp .write_dentry__set_name

.write_dentry__set_name_end:
  # set name len
  mov %cl, DE_NAME_LEN_OFF(%bx)

  # rec len calc
  xor %dx, %dx
  add $0x0B, %cx # add fix size (8), align 4 (3)
  and $0xFFFC, %cx # align 4 mask: 1100

  # set rec len
  mov %cx, DE_REC_LEN_OFF(%bx)

  # write block
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
