# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove File

# TODO no found err

.include "fayfs/de.s"

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

  # read_inode(i_num_hi, i_num_lo)
  #   ret: i_file_size
  #   ret: i_blk
  mov (i_num), %ax
  push %ax
  mov (i_num+0x02), %ax
  push %ax
  call read_inode
  add $0x04, %sp

  # read
  call set_blk_lba
  call read_block
  mov $0x8000, %bx

.cmd_rm__cmp_name:
  # set arg_ptr
  mov (arg_ptr), %si

  # strlen(str)
  #   ret: ax = len
  push %si
  call strlen
  add $0x02, %sp

  # set name len
  xor %cx, %cx
  mov DE_NAME_LEN_OFF(%bx), %cl

  # cond: 0 ? done # HACK add hdl_err
  test %cx, %cx
  jz .cmd_rm__done

  # cond: != ? cmp_name_ne
  cmp %cx, %ax
  jne .cmd_rm__cmp_name_ne

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
  jz .cmd_rm__cmp_name_e

  # ne
  jmp .cmd_rm__cmp_name_ne

.cmd_rm__cmp_name_e:
  # TODO chk file_type

  # rm i_num # HACK only low
  xor %ax, %ax
  mov %ax, DE_I_NUM_LO_OFF(%bx)

  # write
  call write_block

  # done
  jmp .cmd_rm__done

.cmd_rm__cmp_name_ne:
  # add rec len
  mov DE_REC_LEN_OFF(%bx), %cx
  add %cx, %bx

  # next name
  jmp .cmd_rm__cmp_name

.cmd_rm__done:
  call outnl

  # epil
  pop %bx
  pop %di
  pop %si
  ret
