# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

.include "fs.s"

.equ DEO_I_NUM_LO, 0x00
.equ DEO_I_NUM_HI, 0x02
.equ DEO_REC_LEN, 0x04
.equ DEO_NAME_LEN, 0x06
.equ DEO_FILE_TYPE, 0x07
.equ DEO_NAME, 0x08

.equ FIRST_LBA, 0x80

# TEXT
.section .text
.code16

.global add_dentry
.global find_free_dentry
.global set_dentry

# !!! TMP
# inode num -> block num -> block lba calc -> set lba -> find free?

# ENTRY
# add_dentry()
add_dentry:
  call find_free_dentry
  call set_dentry
  ret

# ENTRY
# find_free_dentry()
find_free_dentry:
  # prol
  push %bx

  # set lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

.find_free_dentry__lp:
  # load
  mov DEO_I_NUM_LO(%bx), %ax

  # cond: null ? end
  test %ax, %ax
  or DEO_I_NUM_HI(%bx), %ax
  jz .find_free_dentry__end

  # step
  mov DEO_REC_LEN(%bx), %cx
  add %cx, %bx
  jmp .find_free_dentry__lp

.find_free_dentry__end:
  # ret
  mov %bx, (free_dentry)

  # epil
  pop %bx
  ret

# ENTRY
# set_dentry() !!! TMP Name argv (touch, mkdir)
set_dentry:
  # prol
  push %bx

  # init
  mov (free_dentry), %bx

  # body
  mov (fi_num), %ax
  mov %ax, DEO_I_NUM_LO(%bx)
  mov (fi_num+2), %ax
  mov %ax, DEO_I_NUM_HI(%bx)

  mov $0x80, %al # !!! TMP file 0x80, dir 0x40
  mov %al, DEO_FILE_TYPE(%bx)

  # init
  mov (arg_ptr), %si
  mov %bx, %di
  add $DEO_NAME, %di
  xor %cx, %cx

.set_dentry__set_name:
  # load
  mov (%si), %al

  # cond: null ? set_name_end
  test %al, %al
  jz .set_dentry__set_name_end

  # store
  mov %al, (%di)

  # step
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp .set_dentry__set_name

.set_dentry__set_name_end:
  # set name len
  mov %cl, DEO_NAME_LEN(%bx)

  # rec len calc
  add $0x08, %cx # add fix size
  mov %cx, %ax
  xor %dx, %dx

  mov $0x04, %si
  div %si

  add %dx, %cx # align

  # set rec len
  mov %cx, DEO_REC_LEN(%bx)

  # write block
  call write_block

  # epil
  pop %bx
  ret

# ENTRY
# set_blk_lba() # !!! TMP low high
set_blk_lba:
  # init
  mov (b_num), %ax
  mov $0x08, %cx

  # calc
  mul %cx

  mov $FIRST_LBA, %cx
  add %cx, %ax

  # ret
  mov %ax, (blk_lba)
  ret
