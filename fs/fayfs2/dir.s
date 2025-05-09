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

# TEXT
.section .text
.code16

.global find_free_dentry
.global add_dentry

# !!! TMP
# inode num -> block num -> block lba calc -> set lba -> find free?

# ENTRY
# find_free_dentry()
#   pre: bx = mem ptr
find_free_dentry:
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

  pop %bx
  ret

# ENTRY
# set_dentry() !!! TMP Name argv (touch, mkdir)
set_dentry:
  # prol
  push %bx

  # body
  mov (fi_num), %ax
  mov %ax, DEO_I_NUM_LO(%bx)
  mov (fi_num+2), %ax
  mov %ax, DEO_I_NUM_HI(%bx)

  mov $0x80, %al # !!! TMP file 0x80, dir 0x40
  mov %al, DEO_FILE_TYPE(%bx)

  # init
  mov (arg_ptr), %si
  xor %cx, %cx

.set_dentry__set_name:
  mov $0x00, %al
  mov %al, DEO_NAME(%bx)

  # cond: null ? set_name_end
  test %al, %al
  jz .set_dentry__set_name_end

  # step
  add $0x01, %si
  add $0x01, %cx
  jmp .set_dentry__set_name

.set_dentry__set_name_end:
  # set name len
  mov %cl, DEO_NAME_LEN(%bx)

  # rec len calc
  add $0x08, %cx # add fix size
  mov %cx, %ax

  mov $0x04, %dx
  div %dx

  add %dx, %cx # align

  # set rec len
  mov %cx, DEO_REC_LEN(%bx)

  # epil
  pop %bx
  ret

# ENTRY
# add_dentry(mem_ptr)
add_dentry:
  # prol
  push %bp
  mov %sp, %bp
  push %bx

  # init
  mov 4(%bp), %bx
  
  # body
  mov $0x00, %ax
  mov %ax, DEO_I_NUM_LO(%bx)
  mov $0x00, %ax
  mov %ax, DEO_I_NUM_HI(%bx)

  mov $0x00, %ax
  mov %ax, DEO_REC_LEN(%bx)

  mov $0x00, %al
  mov %al, DEO_NAME_LEN(%bx)

  mov $0x00, %al
  mov %al, DEO_FILE_TYPE(%bx)

  # loop init
  mov $0x00, %al
  mov %al, DEO_NAME(%bx)

  # epil
  pop %bx
  pop %bp
  ret