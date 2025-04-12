# SPDX-License-Identifier: GPL-3.0-or-later
#
# Trim
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

.code16
.section .text

.global trim

# trim(src, dst)
trim:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  mov 4(%bp), %si # src

.trim__left_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .trim__done

  # cond: space != ? left_end
  cmp $0x20, %al
  jne .trim__left_end

  # loop
  add $0x01, %si
  jmp .trim__left_lp

.trim__left_end:
  mov %si, %bx # start char

.trim__find_last_lp:
  # cond: null ? right
  mov (%si), %al
  test %al, %al
  jz .trim__right

  # loop
  add $0x01, %si
  jmp .trim__find_last_lp

.trim__right:
  sub $0x01, %si

.trim__right_lp:
  # cond: space != ? write
  mov (%si), %al
  cmp $0x20, %al
  jne .trim__write

  # loop
  sub $0x01, %si
  jmp .trim__right_lp

.trim__write:
  mov %si, %cx # last char
  mov %bx, %si # start char
  mov 6(%bp), %di # dst

.trim__write_lp:
  # write
  mov (%si), %al
  mov %al, (%di)
  
  # cond: cx == si ? done
  cmp %cx, %si
  je .trim__done

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .trim__write_lp

.trim__done:
  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  pop %bp
  ret
