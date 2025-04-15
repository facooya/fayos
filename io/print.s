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
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si
  mov $0x0E, %ah

.print_str__out_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .print_str__done

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .print_str__out_lp

.print_str__done:
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
  mov $0x0E, %ah

.print_esc__out_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .print_esc__done

  # cond: backslash ? hdl_esc
  cmp $0x5C, %al # backslash
  jz .print_esc__hdl_esc

  # out
  int $0x10

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
  int $0x10

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
  push %ax
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10
  pop %ax
  ret
