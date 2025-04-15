# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Arguments

.code16
.section .text

.global build_args
.global argc
.global argv

.extern cli_buf_split

# !!! .dout() tmp debug for split buffer
.dout:
  mov $cli_buf_split, %si
  mov $0x0E, %ah

.dout_lp:
  mov (%si), %al # load

  # cond: null ? chk
  test %al, %al
  jz .dout_chk

  int $0x10 # out

  # loop
  add $0x01, %si
  jmp .dout_lp

.dout_chk:
  add $0x01, %si
  mov (%si), %al # load

  # cond: null ? done
  test %al, %al
  jz .dout_done

  # loop
  jmp .dout_lp

.dout_done:
  ret

# build_args()
build_args:
  # prol
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  call .dout # !!! tmp

  # init
  call .clear_args
  mov $cli_buf_split, %si
  mov $argv, %di
  xor %bx, %bx # off
  xor %cx, %cx # argc

.build_args__argv_lp:
  mov (%si), %al # load (raw)

  # cond: null ? argc
  test %al, %al
  jz .build_args__argc

  # loop
  add $0x01, %si
  add $0x01, %bx # off (raw)
  jmp .build_args__argv_lp

.build_args__argc:
  add $0x01, %cx # argc

  # write argv
  mov %bx, (%di) # store (argv)
  xor %bx, %bx
  add $0x02, %di # argv

  add $0x01, %si
  mov (%si), %al # load (raw)

  # cond: null ? done
  test %al, %al
  jz .build_args__done

  # loop
  jmp .build_args__argv_lp

.build_args__done:
  # write argc
  mov $argc, %si
  mov %cx, (%si)

  mov $0x0E, %ah
  mov (%si), %al
  add $0x30, %al
  int $0x10

  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  ret

# .clear_args()
.clear_args:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # init
  mov $argv, %si
  mov $argc, %di
  mov (%di), %cx

.clear_args__zero_lp:
  # cond: cx == 0 ? done
  test %cx, %cx
  jz .clear_args__done

  # zero
  mov (%si), %ax # load (argv)
  xor %ax, %ax
  mov %ax, (%si) # store (argv)

  # loop
  add $0x02, %si
  sub $0x01, %cx
  jmp .clear_args__zero_lp

.clear_args__done:
  mov %cx, (%di) # store (argc)

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret

.section .data

# args
argc: .word 0x00
argv: .zero 0x100

# !!! raw: .zero 0x400
