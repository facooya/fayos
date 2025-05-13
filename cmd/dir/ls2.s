# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# List 2 for fayfs 2, Temporary command

.include "fayfs/de.s"

.section .text
.code16

.global cmd_ls2

# ENTRY
# cmd_ls2()
cmd_ls2:
  push %si
  push %bx

  call outnl

  # get i blk
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call get_i_blk
  add $0x04, %sp

  # set blk lba
  call set_blk_lba

  # read block
  call read_block
  mov $0x8000, %bx

.cmd_ls2__out_name:
  # set name ptr
  mov %bx, %si
  add $DE_NAME_OFF, %si

  # get name len
  xor %cx, %cx
  mov DE_NAME_LEN_OFF(%bx), %cl

.cmd_ls2__out_str:
  # cond: 0 ? out_str_end
  test %cx, %cx
  jz .cmd_ls2__out_str_end

  # out
  mov (%si), %al
  call sys_tty_out # !!! TMP

  # step
  add $0x01, %si
  sub $0x01, %cx
  jmp .cmd_ls2__out_str

.cmd_ls2__out_str_end:
  # add rec_len
  mov DE_REC_LEN_OFF(%bx), %ax
  add %ax, %bx

  # cond: null ? end
  test %ax, %ax
  jz .cmd_ls2__end

  # loop
  call outsp
  call outsp
  jmp .cmd_ls2__out_name

.cmd_ls2__end:
  call outnl

  # epil
  pop %bx
  pop %si
  ret
