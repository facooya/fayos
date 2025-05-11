# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Change directory 2 for fayfs 2, Temporary command

.include "fayfs/de.s"

.section .text
.code16

.global cmd_cd2

# !!! TMP read_inode => read_block => cmp_dentry => 
#   cmp_file_type => update_inode_number

# ENTRY
# cmd_cd2()
cmd_cd2:
  push %si
  push %di
  push %bx

  call outnl

  call read_inode

  call set_blk_lba

  # read block
  call read_block
  mov $0x8000, %bx

.cmd_cd2__cmp_name_len:
  # init
  mov (arg_ptr), %si

  # get len
  push %si
  call strlen
  add $0x02, %sp
  # ax = len

  xor %cx, %cx
  mov DE_NAME_LEN_OFF(%bx), %cl

  # cond: 0 ? done
  test %cx, %cx
  jz .cmd_cd2__done

  # cond: != ? cmp_name_ne
  cmp %cx, %ax
  jne .cmd_cd2__cmp_name_ne

  # set name ptr
  mov %bx, %di
  add $DE_NAME_OFF, %di

  # cmp
  push %cx
  push %di
  push %si
  call strncmp
  add $0x06, %sp
  # ax = 0: true, 1: false

  # cond: true ? cmp_name_e
  test %ax, %ax
  jz .cmd_cd2__cmp_name_e

  jmp .cmd_cd2__cmp_name_ne

.cmd_cd2__cmp_name_e:
  # get inode num and blk num
  mov $0x41, %al
  call sys_tty_out # !!! DEBUG

  jmp .cmd_cd2__done

.cmd_cd2__cmp_name_ne:
  mov $0x42, %al
  call sys_tty_out # !!! DEBUG

  # add rec len
  mov DE_REC_LEN_OFF(%bx), %cx
  add %cx, %bx

  # next name
  jmp .cmd_cd2__cmp_name_len

.cmd_cd2__done:
  # epil
  pop %si
  pop %di
  pop %bx
  ret
