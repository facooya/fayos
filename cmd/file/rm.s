# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# rm

# INDEX
# cmd_rm()

# DEPS
# cmd_rm()
#   outnl
#   read_block
#   write_block
#   dap

.code16
.section .text

.global cmd_rm

# cmd_rm()
cmd_rm:
  # prol
  push %si
  push %di
  push %bx

  # set lba
  push $0x80 # !!! TMP root dir
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # set mem ptr
  mov $0x8000, %bx

.cmd_rm__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_rm__cmp_name

  # cond: null ? done
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_rm__done

  # loop
  add $0x02, %bx
  jmp .cmd_rm__find_magic_lp

.cmd_rm__cmp_name:
  # copy ptr (magic)
  mov %bx, %di

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # arg
  xor %dx, %dx
  mov $argv, %si
  add $0x02, %si
  mov (%si), %dx
  mov $raw_buf, %si
  add %dx, %si

.cmd_rm__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_rm__main

  # cond: char != ? skip_dentry
  mov (%si), %al # arg
  cmp (%di), %al # name ptr
  jne .cmd_rm__skip_dentry

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_rm__cmp_name_lp

.cmd_rm__skip_dentry:
  # loop
  add $0x0A, %bx # cat.s [n_skip_dentry]
  jmp .cmd_rm__find_magic_lp

.cmd_rm__main:
  # bit test set
  xor %ax, %ax
  bts $0x07, %ax # msb
  mov %al, 9(%bx) # file type

  call write_block

.cmd_rm__done:
  call outnl

  # epil
  pop %bx
  pop %di
  pop %si
  ret
