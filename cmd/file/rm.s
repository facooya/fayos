# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# rm

# INDEX
# cmd_rm()

# DEPS
# cmd_rm()
#   print_newline
#   read_block
#   write_block
#   dap

.code16
.section .text

.global cmd_rm

.extern print_newline
.extern read_block
.extern write_block
.extern dap

# cmd_rm()
cmd_rm:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  push $0x80 # !!! root dir
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # set mem ptr
  mov $0x8000, %si

.cmd_rm__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_rm__cmp_name

  # cond: null ? done
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_rm__done

  # loop
  add $0x02, %si
  jmp .cmd_rm__find_magic_lp

.cmd_rm__cmp_name:
  # copy ptr (magic)
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # setup
  push %si # main mem ptr
  # mov $cli_buf_arg, %si !!! FIXME

.cmd_rm__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_rm__main

  # cond: char != ? skip_dentry
  mov (%si), %al # cli_buf_arg
  cmp (%di), %al # name ptr
  jne .cmd_rm__skip_dentry

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_rm__cmp_name_lp

.cmd_rm__skip_dentry:
  pop %si # main mem ptr

  # loop
  add $0x0A, %si # cat.s [n_skip_dentry]
  jmp .cmd_rm__find_magic_lp

.cmd_rm__main:
  pop %si # main mem ptr

  # bit test set
  xor %ax, %ax
  bts $0x07, %ax # msb
  mov %al, 9(%si) # file type

  call write_block

.cmd_rm__done:
  call print_newline

  # epil
  pop %ax
  pop %cx
  pop %di
  pop %si
  ret

# -----========== < Command (rm) ==========-----
# === < CODE
