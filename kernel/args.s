# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Arguments

.code16
.section .text

.global trim_raw
.global split_raw
.global build_args
.global clear_raw_buf

.global argc
.global argv
.global raw_buf

.global dout # !!! DEBUG
# !!! dout() tmp debug
dout:
  push %si
  push %ax

  mov $raw_buf, %si
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
  pop %ax
  pop %si
  ret

# trim_raw()
trim_raw:
  # prol
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  # init
  mov $raw_buf, %si
  xor %cx, %cx

.trim_raw__left_lp: # !!! {si}[ ][ ]echo[ ]facooya[ ][ ][0]
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .trim_raw__done

  # cond: space != ? left_end
  cmp $0x20, %al
  jne .trim_raw__left_end

  # loop
  add $0x01, %si
  add $0x01, %cx
  jmp .trim_raw__left_lp

.trim_raw__left_end:
  # !!! si,cx=2
  # !!! [ ][ ]{si}echo[ ]facooya[ ][ ][0]
  mov %si, %di # di = left valid idx
  # !!! di=2

  # !!! for push $raw_buf => push %si
  sub %cx, %si # si = left idx
  xor %cx, %cx

  # TODO
  # push $raw_buf
  # call strlen
  # add $0x02, %sp
  # mov $raw_buf, %si
  # add %cx, %si

.trim_raw__strlen_lp: # !!! tmp strlen
  # !!! [ ][ ]echo[ ]facooya[ ][ ]{si,cx}[0] si,cx=16
  # cond: null ? right
  mov (%si), %al
  test %al, %al
  jz .trim_raw__right

  # loop
  add $0x01, %si
  add $0x01, %cx
  jmp .trim_raw__strlen_lp

.trim_raw__right:
  sub $0x01, %si
  mov %si, %bx # bx = right idx
  # !!! si,bx=15, cx=16
  # !!! [ ][ ]echo[ ]facooya[ ]{si,bx}[ ][0]

.trim_raw__right_lp:
  # !!! si,bx=15 - 2 = 13
  # !!! [ ][ ]echo[ ]facooy{si,bx}a[ ][ ][0]
  # load
  mov (%si), %al

  # cond: space != ? compact
  cmp $0x20, %al
  jne .trim_raw__compact

  # loop
  sub $0x01, %si
  sub $0x01, %bx
  jmp .trim_raw__right_lp

.trim_raw__compact:
  # di = left valid idx !!! 2
  # bx = right valid idx !!! 13
  # cx = str len !!! 16

  # init
  mov $raw_buf, %si # dst

.trim_raw__compact_lp:
  # !!! {si}[ ][ ]{di}echo[ ]facooy{bx}a[ ][ ]{cx}[0]
  # copy
  mov (%di), %al
  mov %al, (%si)
  
  # cond: di == bx ? zero
  cmp %bx, %di
  je .trim_raw__zero

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .trim_raw__compact_lp

.trim_raw__zero:
  # !!! di,bx = right valid idx
  # !!! cx = str len

  # init
  add $0x01, %si

.trim_raw__zero_lp:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .trim_raw__done

  # store zero
  xor %al, %al
  mov %al, (%si)

  # step
  add $0x01, %si
  jmp .trim_raw__zero_lp

.trim_raw__done:
  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  ret

# split_raw()
split_raw:
  # prol
  push %si
  push %di
  push %ax

  # init
  mov $raw_buf, %si
  mov %si, %di

.split_raw__write_lp:
  # load
  mov (%si), %al

  # cond: null ? zero
  test %al, %al
  jz .split_raw__zero

  # cond: space ? skip_spaces
  cmp $0x20, %al
  je .split_raw__skip_spaces

  # store
  mov %al, (%di)

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .split_raw__write_lp

.split_raw__skip_spaces:
  # store null
  xor %al, %al
  mov %al, (%di)
  add $0x01, %di

  # init
  add $0x01, %si

.split_raw__skip_spaces_lp:
  # load
  mov (%si), %al

  # cond: space != ? next
  cmp $0x20, %al
  jne .split_raw__next

  # step
  add $0x01, %si
  jmp .split_raw__skip_spaces_lp

.split_raw__next:
  jmp .split_raw__write_lp

.split_raw__zero:
  # init
  # mov %al, (%di)
  # add $0x01, %di

.split_raw__zero_lp:
  # load
  mov (%di), %al

  # cond: null ? done
  test %al, %al
  jz .split_raw__done

  # zero
  xor %al, %al
  mov %al, (%di)

  # step
  add $0x01, %di
  jmp .split_raw__zero_lp

.split_raw__done:
  # epil
  pop %ax
  pop %di
  pop %si
  ret

# build_args()
build_args:
  # prol
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  # init
  call .clear_args
  mov $raw_buf, %si
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

  # !!! DEBUG
  # mov $0x0E, %ah
  # mov (%si), %al
  # add $0x30, %al
  # int $0x10
  # push $raw_buf
  # call print_str
  # add $0x02, %sp

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

# clear_raw_buf()
clear_raw_buf:
  # prol
  push %si
  push %ax

  # init
  mov $raw_buf, %si

.clear_raw_buf__zero_lp:
  # load
  mov (%si), %al

  # cond: null ? chk_zero
  test %al, %al
  jz .clear_raw_buf__chk_zero

  # store zero
  xor %al, %al
  mov %al, (%si)

  # loop
  add $0x01, %si
  jmp .clear_raw_buf__zero_lp

.clear_raw_buf__chk_zero:
  # next load
  add $0x01, %si
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .clear_raw_buf__done

  # loop
  jmp .clear_raw_buf__zero_lp

.clear_raw_buf__done:
  # epil
  pop %ax
  pop %si
  ret

.section .data

# args
argc: .word 0x00
argv: .zero 0x100

# raw_buf
raw_buf: .zero 0x400
