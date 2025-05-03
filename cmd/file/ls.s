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
#   outnl
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

# cmd_ls()
cmd_ls:
  # prol
  push %si
  push %di
  push %bx

  # set lba
  mov (cwd_lba), %ax # low
  push %ax
  mov (cwd_lba+2), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  call outnl

  # set mem ptr
  mov $0x8000, %bx

.cmd_ls__find_magic_lp:
  # cond: magic ? chk_del
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_ls__chk_del

  # cond: null ? done
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_ls__done

  # loop
  add $0x02, %bx
  jmp .cmd_ls__find_magic_lp

.cmd_ls__chk_del:
  # cond: bit test ? chk_del_end
  xor %ax, %ax
  mov 9(%bx), %al # file type
  bt $0x07, %ax # msb
  jc .cmd_ls__chk_del_end

  # default
  jmp .cmd_ls__read_name

.cmd_ls__chk_del_end:
  # loop
  add $0x0A, %bx # [n_skip_dentry]
  jmp .cmd_ls__find_magic_lp

.cmd_ls__read_name:
  # copy mem ptr
  mov %bx, %di

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size

  # set name ptr
  sub %cx, %di

  # print file name
  push %di
  call puts
  add $0x02, %sp

.cmd_ls__read_name_end:
  # skip dentry [n_skip_dentry]
  add $0x0A, %bx
 
  call outsp
  call outsp
  
  # loop
  jmp .cmd_ls__find_magic_lp

.cmd_ls__done:
  call outnl
  
  # epil
  pop %bx
  pop %di
  pop %si
  ret
