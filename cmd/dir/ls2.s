# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# List 2 for fayfs 2, Temporary command

.section .text
.code16

.global cmd_ls2

# ENTRY
# cmd_ls2()
cmd_ls2:
  push %si
  push %bx

  call outnl

  call read_inode # update i_blk
  call set_blk_lba

  # cwd_i => Inode Table => i_blk[0] => lba !!! TMP
  # push $0x88
  # push $0x00
  # call set_dap_lba
  # add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

.cmd_ls2__out_name:
  # set name ptr
  mov %bx, %si
  add $0x08, %si

  # name len
  xor %cx, %cx
  mov 6(%bx), %cl

  mov $0x0E, %ah

.cmd_ls2__out_str:
  # cond: 0 ? out_str_end
  test %cx, %cx
  jz .cmd_ls2__out_str_end

  # out
  mov (%si), %al
  int $0x10

  # step
  add $0x01, %si
  sub $0x01, %cx
  jmp .cmd_ls2__out_str

.cmd_ls2__out_str_end:
  # add rec_len
  mov 4(%bx), %ax
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
