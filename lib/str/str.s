# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Return string length

.code16
.section .text

.global strlen
.global strcmp

# ENTRY
# strlen(str)
#   ret: ax = len
strlen:
  # prol
  push %bp
  mov %sp, %bp
  push %si

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
  # ret
  mov %cx, %ax

  # epil
  pop %si
  pop %bp
  ret

# ENTRY
# strcmp(src, dst)
#   ret: ax = 0: true, 1: false
#   ret: cx = count
strcmp:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di

  # init
  mov 4(%bp), %si
  mov 6(%bp), %di
  xor %cx, %cx

.strcmp__lp:
  # load
  mov (%si), %al
  mov (%di), %dl

  # cond: null == al ? chk
  test %al, %al
  jz .strcmp__chk

  # cond: null == dl ? ne
  test %dl, %dl
  jz .strcmp__ne
  
  # cond: != ? ne
  cmp %al, %dl
  jne .strcmp__ne

  # step
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp .strcmp__lp

.strcmp__chk:
  # cond: null ? e
  test %dl, %dl
  jz .strcmp__e

  # default
  jmp .strcmp__ne

.strcmp__e:
  xor %ax, %ax
  jmp .strcmp__done

.strcmp__ne:
  mov $0x01, %ax
  jmp .strcmp__done

.strcmp__done:
  # epil
  pop %di
  pop %si
  pop %bp
  ret
