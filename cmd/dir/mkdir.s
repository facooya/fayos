# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make directory

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
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  mov $0x8000, %si # mem ptr

.cmd_mkdir__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_mkdir__cmp_name

  # cond: null ? write_name
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_mkdir__write_name

  # loop
  add $0x02, %si
  jmp .cmd_mkdir__find_magic_lp

.cmd_mkdir__cmp_name:
  # copy ptr (magic)
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # setup
  push %si # main mem ptr !!! danger
  mov $cli_buf_arg, %si

.cmd_mkdir__cmp_name_lp:
  # cond: 0 ? err_exist
  test %cx, %cx
  jz .cmd_mkdir__err_exist

  # cond: char != ? cmp_name_end
  mov (%si), %al # cli_buf_arg
  cmp (%di), %al # name ptr
  jne .cmd_mkdir__cmp_name_end

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_mkdir__cmp_name_lp

.cmd_mkdir__cmp_name_end:
  pop %si # main mem ptr

  # loop
  add $0x0A, %si
  jmp .cmd_mkdir__find_magic_lp

# .cmd_mkdir__find_free_lp:
#   # cond: null ? write_name
#   mov (%si), %ax
#   test %ax, %ax
#   or 2(%si), %ax
#   jz .cmd_mkdir__write_name

#   # loop
#   add $0x02, %si
#   jmp .cmd_mkdir__find_free_lp

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
  push $0x0D # directory
  call write_dentry__type
  add $0x02, %sp

  # write dentry data lba
  mov (free_lba), %ax
  mov %ax, 4(%si)
  mov (free_lba+2), %ax
  mov %ax, 6(%si)

  call write_block

  call write_meta

  # allocate
  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)

.cmd_mkdir__done:
  call print_newline

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret

.cmd_mkdir__err_exist:
  pop %si
  
  call print_newline

  push $.cmd_mkdir__err_exist_msg
  call print_str
  add $0x02, %sp

  jmp .cmd_mkdir__done

.section .data

.cmd_mkdir__err_exist_msg: .asciz "Already exists."
