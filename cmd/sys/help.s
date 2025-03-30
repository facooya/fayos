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

# DEPS
# cmd_help()
# - print_newline
# - cli_cmd_map

.code16
.section .text

.global cmd_help

.extern print_newline
.extern cli_cmd_map

# cmd_help()
cmd_help:
  # prol
  push %si
  push %ax
  push %bx

  # set
  mov $cli_cmd_map, %si
  mov $0x0E, %ah

.cmd_help__chk_addr_lp:
  # cond: null ? done
  mov (%si), %bx
  test %bx, %bx
  jz .cmd_help__done

  call print_newline

  add $0x02, %si # cli_cmd_map (cmd_str)

.cmd_help__out_char_lp:
  # cond: null ? out_char_end
  mov (%si), %al
  test %al, %al
  jz .cmd_help__out_char_end

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .cmd_help__out_char_lp

.cmd_help__out_char_end:
  # loop
  add $0x01, %si # cli_cmd_map (cmd_addr)
  jmp .cmd_help__chk_addr_lp

.cmd_help__done:
  # epil
  pop %bx
  pop %ax
  pop %si
  ret
