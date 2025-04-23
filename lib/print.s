# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# print

# INDEX
# print_str()
# print_esc()
# print_newline()

.code16
.section .text

.global print_str
.global print_esc
.global print_newline

# print_str(str_addr)
print_str:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # init
  mov 4(%bp), %si

  # load
  mov (%si), %al

  # cond: dquote ? ignore_dquote
  cmp $0x22, %al
  je .print_str__ignore_dquote

.print_str__out_lp:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .print_str__done

  # cond: backslash ? chk_esc
  cmp $0x5C, %al
  je .print_str__chk_esc

  # cond: dquote ? ignore_dquote
  cmp $0x22, %al
  je .print_str__ignore_dquote

  call out_chr

  # step
  add $0x01, %si
  jmp .print_str__out_lp

.print_str__chk_esc:
  # pre: si = backslash

  # load
  mov 1(%si), %al

  # cond: dquote ? out_dquote
  cmp $0x22, %al
  je .print_str__out_dquote

  # load backslash
  mov (%si), %al

  call out_chr

  # step
  add $0x01, %si
  jmp .print_str__out_lp


.print_str__ignore_dquote:
  # pre: si = dquote

  # step
  add $0x01, %si
  jmp .print_str__out_lp

.print_str__out_dquote:
  # pre: ah = out
  # pre: al = dquote

  call out_chr

  # continue
  add $0x01, %si
  jmp .print_str__out_lp

.print_str__done:
  # epil
  pop %ax
  pop %si
  pop %bp
  ret

# print_esc(str_addr)
print_esc:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si

.print_esc__out_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .print_esc__done

  # cond: backslash ? hdl_esc
  cmp $0x5C, %al # backslash
  jz .print_esc__hdl_esc

  call out_chr

  # loop
  add $0x01, %si
  jmp .print_esc__out_lp

.print_esc__hdl_esc:
  add $0x01, %si
  mov (%si), %al

  # cond: n ? esc_n
  cmp $0x6E, %al # n
  jz .print_esc__hdl_esc_n

  # out
  mov $0x5C, %al # backslash
  call out_chr

  # loop
  jmp .print_esc__out_lp

.print_esc__hdl_esc_n:
  call print_newline

  # end
  jmp .print_esc__hdl_esc_end

# .print_esc__hdl_esc_*: # more escape char here

.print_esc__hdl_esc_end:
  # loop
  add $0x01, %si
  jmp .print_esc__out_lp

.print_esc__done:
  pop %ax
  pop %si
  pop %bp
  ret

# print_newline()
print_newline:
  mov $0x0D, %al # CR
  call out_chr
  mov $0x0A, %al # LF
  call out_chr
  ret
