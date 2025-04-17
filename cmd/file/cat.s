# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# cat

# INDEX
# cmd_cat()

# DEPS
# cmd_cat()
#   print_newline
#   read_block
#   write_block !!! redir
#   set_dap_lba

# NOTE
# [n_skip_dentry]
#   2 (magic num)
#   + 1 (name size)
#   + 1 (padding size)
#   + 4 (block entry)
#   + 1 (entry level)
#   + 1 (file type)
#   = 10 = 0x0A

.code16
.section .text

.global cmd_cat

.extern print_newline
.extern read_block
.extern write_block
.extern set_dap_lba

# cmd_cat()
cmd_cat:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  # push $0x80 # !!! root dir
  # push $0x00
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  call print_newline

  # set mem ptr
  mov $0x8000, %si

.cmd_cat__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_cat__cmp_name

  # cond: null ? done
  mov (%si), %ax
  or 2(%si), %ax
  jz .cmd_cat__done

  # loop
  add $0x02, %si
  jmp .cmd_cat__find_magic_lp

.cmd_cat__cmp_name:
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

  # arg
  mov $argv, %si
  add $0x02, %si
  mov (%si), %cx
  mov $raw_buf, %si
  add %cx, %si

.cmd_cat__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_cat__main

  # cond: char != ? skip_dentry
  mov (%si), %al # arg
  cmp (%di), %al # name ptr
  jne .cmd_cat__skip_dentry

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_cat__cmp_name_lp

.cmd_cat__skip_dentry:
  pop %si # main mem ptr

  # skip dentry [n_skip_dentry]
  add $0x0A, %si

  # loop
  jmp .cmd_cat__find_magic_lp

.cmd_cat__main:
  pop %si # main mem ptr

  # cond: 1 != ? done
  # !!! temp, only entry level 1
  mov 8(%si), %al # entry level
  cmp $0x01, %al
  jnz .cmd_cat__done

  # set lba
  mov 4(%si), %ax # low
  push %ax
  mov 6(%si), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp
  
  call read_block

  # set data mem ptr
  mov $0x8006, %si

  mov $0x0E, %ah

.cmd_cat__out_data:
  # cond: null ? done
  movb (%si), %al
  test %al, %al
  jz .cmd_cat__done

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .cmd_cat__out_data

.cmd_cat__done:
  call print_newline

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret
