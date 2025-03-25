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
# cmd_help()

# DEPS
# src/inc/cmd/cmd_table.inc (DATA: cmd_table)
# src/inc/sys/kbd.inc (FUNC: newline)

# === < PREVIEW
# ===
# === > CODE

.code16

# -== > Command Help

cmd_help:
_cmd_help__prol:
  push %si
  push %ax
  push %bx

# --= > Check Address

_cmd_help__chk_addr_set:
  mov $cmd_table, %si # cmd_table.inc
  mov $0x0E, %ah # out set

_cmd_help__chk_addr_lp:
  # Cond: null ? chk_addr_end
  mov (%si), %bx
  test %bx, %bx
  jz _cmd_help__chk_addr_end

  # Else
  call newline # kbd.inc
  # SI: cmd_addr, SI+2: cmd_byte
  add $0x02, %si

# --- > Out Byte

_cmd_help__out_byte_lp:
  # Cond: null ? out_byte_end
  mov (%si), %al
  test %al, %al
  jz _cmd_help__out_byte_end

  # Out
  int $0x10

  # Loop
  add $0x01, %si
  jmp _cmd_help__out_byte_lp

_cmd_help__out_byte_end:
  # SI: null, SI+1: cmd_addr
  add $0x01, %si

  # Loop
  jmp _cmd_help__chk_addr_lp

# --- < Out Byte

_cmd_help__chk_addr_end:

# --= < Check Address

_cmd_help__epil:
  pop %bx
  pop %ax
  pop %si

_cmd_help__done:
  #call newline
  ret

# -== < Command Help
# ===
# === < CODE
