# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# touch

# INDEX
# cmd_touch()

# DEPS
# cmd_touch()
#   read_block
#   write_block
#   write_dentry
#   print_newline
#   cwd_lba
#   write_meta
#   free_lba

.code16
.section .text

.global cmd_touch

.extern read_block
.extern write_block
.extern write_dentry
.extern print_newline
.extern cwd_lba
.extern write_meta
.extern free_lba

# cmd_touch()
cmd_touch:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  movw (cwd_lba), %ax
  push %ax
  movw (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # set mem ptr
  mov $0x8000, %si

.cmd_touch__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_touch__cmp_name

  # cond: null ? write_name
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_touch__write_name

  # loop
  add $0x02, %si
  jmp .cmd_touch__find_magic_lp

.cmd_touch__cmp_name:
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

  # arg
  mov $argv, %si
  add $0x02, %si
  mov (%si), %cx
  mov $raw_buf, %si
  add %cx, %si

.cmd_touch__cmp_name_lp:
  # cond: 0 ? err_exist
  test %cx, %cx
  jz .cmd_touch__err_exist

  # cond: char != ? cmp_name_end
  mov (%si), %al # arg
  cmp (%di), %al # name ptr
  jne .cmd_touch__cmp_name_end

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_touch__cmp_name_lp

.cmd_touch__cmp_name_end:
  pop %si # main mem ptr

  # loop
  add $0x0A, %si
  jmp .cmd_touch__find_magic_lp

.cmd_touch__write_name:
  # arg
  mov $argv, %di
  add $0x02, %di
  mov (%di), %cx
  mov $raw_buf, %di
  add %cx, %di

  xor %cx, %cx

.cmd_touch__write_name_lp:
  # cond: null ? write_name_end
  mov (%di), %al # arg
  test %al, %al
  jz .cmd_touch__write_name_end

  # write mem
  mov %al, (%si)

  # loop
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp .cmd_touch__write_name_lp

.cmd_touch__write_name_end:
  # add null char
  add $0x01, %si # mem ptr
  add $0x01, %cx # name size

  # write dentry
  push %cx
  call write_dentry
  add $0x02, %sp

  # set data lba (dentry)
  mov (free_lba), %ax
  mov %ax, 4(%si)
  mov (free_lba+2), %ax
  mov %ax, 6(%si)

  call write_block

  # write meta !!! test
  call write_meta

  # allocate free lba, !!! low only, seq: write_meta
  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)

.cmd_touch__done:
  call print_newline

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret

.cmd_touch__err_exist:
  pop %si
  
  call print_newline

  push $.cmd_touch__err_exist_msg
  call print_str
  add $0x02, %sp

  jmp .cmd_touch__done

.section .data

.cmd_touch__err_exist_msg: .asciz "Already exists."
