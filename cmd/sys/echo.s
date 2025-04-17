# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# echo

# INDEX
# cmd_echo()
# 
# .cmd_echo__opt_err
# .cmd_echo__opt_flag

# DEPS
# cmd_echo()
#   print_newline
#   hdl_cli_opt_err

# NOTE
# [n_cmd_echo__opt_flag]
#   0: e (escape)
#   1: n (no-newline)

.code16
.section .text

.global cmd_echo

.extern hdl_cli_opt_err
.extern print_newline
.extern cli_buf_stdout

# cmd_echo()
cmd_echo:
  # prol
  push %si
  push %ax
  push %bx

  # set opt
  # mov $cli_buf_opt, %si !!! FIXME
  mov $.cmd_echo__opt_flag, %si # !!! TMP
  mov $.cmd_echo__opt_flag, %bx

.cmd_echo__chk_opt_lp:
  # cond: null ? main
  mov (%si), %al # cli_buf_opt
  test %al, %al
  jz .cmd_echo__main

  # cond: e ? set_opt_flag_e
  cmp $0x65, %al # e
  jz .cmd_echo__set_opt_e

  # cond: n ? set_opt_n
  cmp $0x6E, %al # n
  jz .cmd_echo__set_opt_n

  # opt err
  jmp .cmd_echo__opt_err

.cmd_echo__set_opt_e:
  btsw $0x00, (%bx) # opt_flag
  add $0x01, %si
  jmp .cmd_echo__chk_opt_lp

.cmd_echo__set_opt_n:
  btsw $0x01, (%bx) # opt_flag
  add $0x01, %si
  jmp .cmd_echo__chk_opt_lp

.cmd_echo__main:
  call print_newline

  # cond: e ? main_opt_e
  btw $0x0, (%bx) # opt_flag
  jc .cmd_echo__main_opt_e

  # default
  # arg !!! TEST
  mov $argv, %di
  add $0x02, %di
  mov (%di), %cx
  mov $raw_buf, %si
  add %cx, %si

  # !!! DEBUG
  # mov $0x0E, %ah
  # mov %cl, %al
  # add $0x30, %al
  # int $0x10

  push %si
  call print_str
  add $0x02, %sp

  # skip opt e
  jmp .cmd_echo__main_opt_e_end

.cmd_echo__main_opt_e:
  # push $cli_buf_arg !!! FIXME
  call print_esc
  add $0x02, %sp

.cmd_echo__main_opt_e_end:
  # cond: n ? main_opt_n
  btw $0x1, (%bx) # opt_flag
  jc .cmd_echo__main_opt_n

  # default
  call print_newline

  # skip opt n
  jmp .cmd_echo__main_opt_n_end

.cmd_echo__main_opt_n:
  nop

.cmd_echo__main_opt_n_end:
  nop
  # next opt cond
  # default
  # skip opt

.cmd_echo__done:
  # init opt flag
  xor %ax, %ax
  mov %ax, (%bx)

  # epil
  pop %bx
  pop %ax
  pop %si
  ret

# .cmd_echo__opt_err
.cmd_echo__opt_err:
  call print_newline

  # print opt err char
  mov $0x0E, %ah
  mov (%si), %al # opt err char
  int $0x10
  mov $0x3A, %al # colon
  int $0x10
  mov $0x20, %al # space
  int $0x10

  # init opt flag
  xor %ax, %ax
  mov %ax, (%bx)

  # epil
  pop %bx
  pop %ax
  pop %si

  # print common err msg
  # jmp hdl_cli_opt_err !!! FIXME
  jmp .cmd_echo__done # !!! TMP

.section .data

# .cmd_echo__opt_flag [n_cmd_echo__opt_flag]
.cmd_echo__opt_flag: .word 0x00
