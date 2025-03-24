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

# === > CODE

.code16

# -----========== > Command Help ==========-----

cmd_help:
  mov $cmd_table, %si
  mov $tmp_buf, %di

cmd_help_check_cmd_addr:
  # Compare Address Null
  mov (%si), %bx
  test %bx, %bx
  jz cmd_help_exit

  # This Command Char
  add $0x02, %si # Addr Cmd Char
  jmp cmd_help_loop_cmd_char

cmd_help_loop_cmd_char:
  # Compare Char Null
  mov (%si), %al
  test %al, %al
  jz cmd_help_output

  # Save cmd_char => tmp_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp cmd_help_loop_cmd_char

cmd_help_output:
  # Next Point [SI], [DI]
  inc %si
  inc %di

  # Last Null [DI]
  xor %al, %al
  mov %al, (%di)

  # Newline
  call newline

  # print_str() AND init_tmp_buf() Using [SI]
  push %si

  # Print tmp_buf
  push $tmp_buf # Output tmp_buf
  call print_str
  add $0x02, %sp

  call init_tmp_buf # Init tmp_buf
  pop %si

  # Set tmp_buf
  mov $tmp_buf, %di

  # Next Command Check
  jmp cmd_help_check_cmd_addr

cmd_help_exit:
  # Newline
  call newline

  # Return
  ret

# -----========== < Command Help ==========-----
# === < CODE
