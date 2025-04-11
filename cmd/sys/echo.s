# FAYOS - FAcooYa Operating System
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
  mov $cli_buf_opt, %si
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
  push $cli_buf_arg
  call print_str
  add $0x02, %sp

  # skip opt e
  jmp .cmd_echo__main_opt_e_end

.cmd_echo__main_opt_e:
  push $cli_buf_arg
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
  jmp hdl_cli_opt_err

.section .data

# .cmd_echo__opt_flag [n_cmd_echo__opt_flag]
.cmd_echo__opt_flag: .word 0x00
