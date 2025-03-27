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

# =============== > PRIVIEW ===============

# LABEL
# err_cmd
# err_opt
# err_disk

# DEPS
# /sys/kbd.inc (FUNC: newline())
# /lib/print.inc (FUNC: print_str(msg))

# =============== < PRIVIEW ===============
# =============== > CODE ===============

.code16
.section .text

#.global err_cmd, err_opt, err_disk
.global err_opt, err_disk

.extern newline # kbd.s
.extern print_str # print.s

# -----========== > Command ==========-----

__err_cmd: # !!! err_cmd => cli.s
  call newline # kbd.inc

  # Print
  push $_err_cmd__msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc
  ret

# -----========== < Command ==========-----
# -----========== > Option ==========-----

err_opt:
  # Print
  push $_err_opt__msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc
  ret

# -----========== < Option ==========-----
# -----========== > Disk ==========-----

err_disk:
  call newline # kbd.inc

  # Print
  push $_err_disk__msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc
  ret

# -----========== < Disk ==========-----

# =============== < CODE ===============
# =============== > DATA ===============

.section .data

_err_cmd__msg: .asciz "Command not found. Try \"help\" for a list of commands."
_err_opt__msg: .asciz "Invalid option."
_err_disk__msg: .asciz "Disk Error."

# =============== < DATA ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
