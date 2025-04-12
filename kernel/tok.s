# SPDX-License-Identifier: GPL-3.0-or-later
#
# Tokenizer
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

.code16
.section .text

.global trim
.global norm_ws

.extern cli_buf_raw
.extern cli_buf_norm
.extern cli_buf_trim

# norm_ws()
norm_ws:
  # prol
  push %si
  push %di
  push %ax

  mov $cli_buf_raw, %si
  mov $cli_buf_norm, %di

.norm_ws__trim_lp:
  # cond: null ? trim_end
  mov (%si), %al
  test %al, %al
  jz .norm_ws__trim_end

  # cond: space ? trim_sp_lp
  cmp $0x20, %al
  je .norm_ws__trim_sp_lp

  # write
  mov %al, (%di)

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .norm_ws__trim_lp

.norm_ws__trim_sp_lp:
  # cond: null ? trim_end
  mov (%si), %al
  test %al, %al
  jz .norm_ws__trim_end

  # cond: space != ? trim_sp_end
  cmp $0x20, %al
  jne .norm_ws__trim_sp_end

  # loop
  add $0x01, %si
  jmp .norm_ws__trim_sp_lp

.norm_ws__trim_sp_end:
  # add space
  mov $0x20, %al
  mov %al, (%di)
  add $0x01, %di

  # loop
  jmp .norm_ws__trim_lp

.norm_ws__trim_end:
  push $cli_buf_norm
  call print_str
  add $0x02, %sp

  # epil
  pop %ax
  pop %di
  pop %si
  ret

trim:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  mov $cli_buf_raw, %si
  mov $cli_buf_trim, %di

.trim__left_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .trim__done

  # cond: space != ? next
  cmp $0x20, %al
  jne .trim__next

  # loop
  add $0x01, %si
  jmp .trim__left_lp

.trim__next:
  push %si # start char

.trim__end_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .trim__right

  # loop
  add $0x01, %si
  jmp .trim__end_lp

.trim__right:
  sub $0x01, %si

.trim__right_lp:
  # cond: space != ? right_end
  mov (%si), %al
  cmp $0x20, %al
  jne .trim__right_end

  # loop
  sub $0x01, %si
  jmp .trim__right_lp

.trim__right_end:
  mov %si, %cx # last char
  pop %si # start char

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
  pop %ax
  pop %di
  pop %si
  ret
