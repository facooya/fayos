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

# === > PREVIEW

# FUNC
# cmd_exec()

# DEPS
# src/inc/cmd/cmd_table.inc (DATA: cmd_table)
# src/inc/cmd/cmd_tok.inc (FUNC: cli_tok)
# src/inc/lib/buf.inc (DATA: cmd_buf)
# src/inc/sys/err.inc (LABEL: err_cmd)

# === < PREVIEW
# ===
# === > CODE

.code16
.global cmd_exec

# -== > Execute

cmd_exec:
  call cli_tok # tok.inc

  mov $cmd_table, %si # cmd_table.inc

_cmd_exec__chk_addr:
  # Null ? not_found
  mov (%si), %bx
  test %bx, %bx
  jz err_cmd # ref: err.inc

_cmd_exec__cmp_cmd:
  add $0x02, %si # cmd_table byte
  mov $cli_buf_cmd, %di

_cmd_exec__cmp_cmd_lp:
  # Char != : next_lp
  mov (%si), %al
  cmp (%di), %al
  jne _cmd_exec__next_lp

  # Found
  test %al, %al
  jz _cmd_exec__call

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cmd_exec__cmp_cmd_lp

_cmd_exec__next_lp:
  # Char
  mov (%si), %al
  test %al, %al
  jz _cmd_exec__next_end

  # Loop
  add $0x01, %si
  jmp _cmd_exec__next_lp

_cmd_exec__next_end:
  add $0x01, %si
  jmp _cmd_exec__chk_addr

_cmd_exec__call:
  call *%bx # Call

_cmd_exec__done:
  ret

# -== < Execute
# === < CODE
