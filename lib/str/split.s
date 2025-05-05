# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Split

.code16
.section .text

.global split

# split(src, dst)
split:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %ax

  mov 4(%bp), %si
  mov 6(%bp), %di

.split__write_lp:
  mov (%si), %al # load

  # cond: null ? write_end
  test %al, %al
  jz .split__write_end

  # cond: space ? skip_space
  cmp $0x20, %al
  je .split__skip_space

  mov %al, (%di) # store

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .split__write_lp

.split__skip_space:
  # !!! <src> echo{si}[ ][ ] => echo[ ]{si}[ ]
  # !!! <dst> echo{di} => echo[0]{di}
  # store null
  mov $0x00, %al
  mov %al, (%di)

  add $0x01, %si
  add $0x01, %di

.split__skip_space_lp: # !!! <src> echo[ ][ ]{si}facooya[0]
  mov (%si), %al # load

  # cond: space != ? next
  cmp $0x20, %al
  jne .split__next

  # loop
  add $0x01, %si
  jmp .split__skip_space_lp

.split__next:
  # loop
  jmp .split__write_lp

.split__write_end: # !!!

.split__done:
  # epil
  pop %ax
  pop %di
  pop %si
  pop %bp
  ret
