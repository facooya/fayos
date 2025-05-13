# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Change directory

# FIXME no dir

.include "fayfs/de.s"

# DATA
.section .data

.no_found_err_msg: .asciz "Not found directory."

.section .text
.code16

.global cmd_cd

# ENTRY
# cmd_cd()
cmd_cd:
  # prol
  push %si
  push %di
  push %bx

  # get i blk
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call get_i_blk
  add $0x04, %sp

  call set_blk_lba

  # read block
  call read_block
  mov $0x8000, %bx

.cmd_cd__cmp_name_len:
  # init
  mov (arg_ptr), %si

  # get len
  push %si
  call strlen
  add $0x02, %sp
  # ax = len

  # set name len
  xor %cx, %cx
  mov DE_NAME_LEN_OFF(%bx), %cl

  # cond: 0 ? hdl_no_found_err
  test %cx, %cx
  jz .hdl_no_found_err

  # cond: != ? cmp_name_ne
  cmp %cx, %ax
  jne .cmd_cd__cmp_name_ne

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
  jz .cmd_cd__cmp_name_e

  # ne
  jmp .cmd_cd__cmp_name_ne

.cmd_cd__cmp_name_e:
  # !!! FIXME chk file type

  # get dst inode num
  mov DE_I_NUM_LO_OFF(%bx), %ax
  mov %ax, (i_num)
  mov DE_I_NUM_HI_OFF(%bx), %ax
  mov %ax, (i_num+0x02)

  # get i blk
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call get_i_blk
  add $0x04, %sp

  # done
  jmp .cmd_cd__done

.cmd_cd__cmp_name_ne:
  # add rec len
  mov DE_REC_LEN_OFF(%bx), %cx
  add %cx, %bx

  # next name
  jmp .cmd_cd__cmp_name_len

.cmd_cd__done:
  call outnl

  # epil
  pop %si
  pop %di
  pop %bx
  ret

# ERR
.hdl_no_found_err:
  call outnl

  push $.no_found_err_msg
  call puts
  add $0x02, %sp

  jmp .cmd_cd__done
