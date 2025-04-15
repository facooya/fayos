# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Tokenizer

.code16
.section .text

.global tok

# tok(src, argc, argv)
tok:
  # prol
  push %bp
  mov %sp, %bp

  

  # epil
  pop %bp
  ret

# norm_ws()
norm_ws:
  # prol
  push %si
  push %di
  push %ax

  mov $cli_buf_trim, %si
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
