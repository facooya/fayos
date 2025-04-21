# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# help

# INDEX
# cmd_help()

# DEPS
# cmd_help()
#   print_newline
#   cmd_map

.code16
.section .text

.global cmd_help

.extern print_newline
.extern cmd_map

# cmd_help()
cmd_help:
  # prol
  push %si
  push %ax
  push %bx

  # set
  mov $cmd_map, %si
  mov $0x0E, %ah

.cmd_help__chk_addr_lp:
  # cond: null ? done
  mov (%si), %bx
  test %bx, %bx
  jz .cmd_help__done

  call print_newline

  add $0x02, %si # cmd_map (cmd_str)

.cmd_help__out_char_lp:
  # cond: null ? out_char_end
  mov (%si), %al
  test %al, %al
  jz .cmd_help__out_char_end

  call out_chr

  # loop
  add $0x01, %si
  jmp .cmd_help__out_char_lp

.cmd_help__out_char_end:
  # loop
  add $0x01, %si # cmd_map (cmd_addr)
  jmp .cmd_help__chk_addr_lp

.cmd_help__done:
  # epil
  pop %bx
  pop %ax
  pop %si
  ret
