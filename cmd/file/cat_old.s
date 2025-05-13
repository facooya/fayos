# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# cat

# INDEX
# cmd_cat()

# NOTE
# [n_skip_dentry]
#   2 (magic num)
#   + 1 (name size)
#   + 1 (padding size)
#   + 4 (block entry)
#   + 1 (entry level)
#   + 1 (file type)
#   = 10 = 0x0A

.section .text
.code16

.global cmd_cat_old

# cmd_cat()
cmd_cat_old:
  # prol
  push %si
  push %di
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

  call outnl

.cmd_cat__find_magic_lp:
  # cond: magic ? strcmp
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_cat__strcmp

  # cond: null ? done
  mov (%bx), %ax
  or 2(%bx), %ax
  jz .cmd_cat__done

  # step
  add $0x02, %bx
  jmp .cmd_cat__find_magic_lp

.cmd_cat__strcmp:
  # copy ptr (magic)
  mov %bx, %si

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size

  # init {strcmp}
  sub %cx, %si
  mov (arg_ptr), %di

  # call {strcmp}
  push %di
  push %si
  call strcmp
  add $0x04, %sp
  # ax = ret code
  # cx = count

  # chk {strcmp}
  # cond: equal ? main
  test %ax, %ax
  jz .cmd_cat__main

  # loop
  add $0x0A, %bx # [n_skip_dentry]
  jmp .cmd_cat__find_magic_lp

.cmd_cat__main:
  # cond: 1 != ? done
  # !!! TMP only entry level 1
  mov 8(%bx), %al # entry level
  cmp $0x01, %al
  jnz .cmd_cat__done

  # set lba
  mov 4(%bx), %ax # low
  push %ax
  mov 6(%bx), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp
  
  call read_block

  # set data mem ptr # !!! TMP
  mov $0x8006, %bx

  push %bx
  call puts
  add $0x02, %sp

.cmd_cat__done:
  call outnl

  # epil
  pop %bx
  pop %di
  pop %si
  ret
