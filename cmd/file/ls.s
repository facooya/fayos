# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# ls

# INDEX
# cmd_ls()

# DEPS
# cmd_ls()
#   set_dap_lba
#   read_block
#   print_newline
#   cwd_lba

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

.global cmd_ls

.extern read_block
.extern print_newline
.extern cwd_lba

# cmd_ls() !!! current dir
cmd_ls:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  mov (cwd_lba), %ax # low
  push %ax
  mov (cwd_lba+2), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  call print_newline

  # set mem ptr
  mov $0x8000, %si

.cmd_ls__find_magic_lp:
  # cond: magic ? chk_del
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_ls__chk_del

  # cond: null ? done
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_ls__done

  # loop
  add $0x02, %si
  jmp .cmd_ls__find_magic_lp

.cmd_ls__chk_del:
  # cond: bit test ? chk_del_end
  xor %ax, %ax
  mov 9(%si), %al # file type
  bt $0x07, %ax # msb
  jc .cmd_ls__chk_del_end

  # default
  jmp .cmd_ls__read_name

.cmd_ls__chk_del_end:
  # loop
  add $0x0A, %si # [n_skip_dentry]
  jmp .cmd_ls__find_magic_lp

.cmd_ls__read_name:
  # copy mem ptr
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set name ptr
  sub %cx, %di

  mov $0x0E, %ah

.cmd_ls__read_name_lp:
  # cond: null ? read_name_end
  mov (%di), %al
  test %al, %al
  jz .cmd_ls__read_name_end

  # out !!! HACK: sys violation
  call sys_out_chr

  # loop
  add $0x01, %di
  jmp .cmd_ls__read_name_lp

.cmd_ls__read_name_end:
  # skip dentry [n_skip_dentry]
  add $0x0A, %si
 
  # division
  mov $0x20, %al # space
  
  # out !!! HACK: sys violation
  call sys_out_chr
  call sys_out_chr
  
  # loop
  jmp .cmd_ls__find_magic_lp

.cmd_ls__done:
  call print_newline
  
  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret
