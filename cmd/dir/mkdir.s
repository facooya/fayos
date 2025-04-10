# SPDX-License-Identifier: GPL-3.0-or-later
#
# Make directory
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

# INDEX
# cmd_mkdir()

# DEPS
# cmd_mkdir()
#   set_dap_lba
#   read_block
#   write_block
#   dap

.code16
.section .text

.global cmd_mkdir

.extern print_newline
.extern set_dap_lba
.extern read_block
.extern write_block
.extern dap
.extern wirte_meta
.extern write_dentry
.extern write_dentry__type
.extern cwd_lba
.extern free_lba
.extern cli_buf_arg

# cmd_mkdir()
cmd_mkdir:
  # prol

  # set lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  mov $0x8000, %si # mem ptr

.cmd_mkdir__find_free_lp:
  # cond: null ? write_name
  mov (%si), %ax
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_mkdir__write_name

  # loop
  add $0x02, %si
  jmp .cmd_mkdir__find_free_lp

.cmd_mkdir__write_name:
  mov $cli_buf_arg, %di
  xor %cx, %cx

.cmd_mkdir__write_name_lp:
  # cond: null ? write_name_end
  mov (%di), %al # cli_buf_arg
  test %al, %al
  jz .cmd_mkdir__write_name_end

  # write mem
  mov %al, (%si)

  # loop
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp .cmd_mkdir__write_name_lp

.cmd_mkdir__write_name_end:
  # add null char
  add $0x01, %si # mem ptr
  add $0x01, %cx # name size

  # write dentry
  push %cx
  call write_dentry
  add $0x02, %sp

  # write dentry type
  push $0x0D
  call write_dentry__type
  add $0x02, %sp

  # write dentry data lba
  mov (free_lba), %ax
  mov %ax, 4(%si)
  mov (free_lba+2), %ax
  mov %ax, 6(%si)

  call write_block

  call write_meta

  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)

  call print_newline

  # epil
  ret
