# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Return string length

.code16
.section .text

.global strlen

# strlen()
strlen:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # init
  mov 4(%bp), %si
  xor %cx, %cx

.strlen__lp:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .strlen__done

  # step
  add $0x01, %si
  add $0x01, %cx
  jmp .strlen__lp

.strlen__done:
  # epil
  pop %ax
  pop %si
  pop %bp
  ret
