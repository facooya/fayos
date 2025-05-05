# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove File

# INDEX
# cmd_rm()
# DATA
.section .data

.no_dir_err_msg: .asciz "No found directory."

# TEXT
.section .text
.code16

.global cmd_rm

# ENTRY
# cmd_rm()
cmd_rm:
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

  # set mem ptr
  mov $0x8000, %bx

.cmd_rm__find_magic_lp:
  # cond: magic ? strcmp
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_rm__strcmp

  # cond: null ? done
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_rm__done

  # loop
  add $0x02, %bx
  jmp .cmd_rm__find_magic_lp

.cmd_rm__strcmp:
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
  jz .cmd_rm__main

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

.hdl_not_file_err:
  call outnl

  push $.no_dir_err_msg
  call puts
  add $0x02, %sp

  jmp .cmd_rm__done
