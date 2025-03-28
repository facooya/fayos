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
.section .text

.global cmd_rm

# -----========== > Command (rm) ==========-----

cmd_rm:
_cmd_rm__run:
  # Remov Arg !!!!!!

  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  #jc err_disk

  mov $0x8000, %si

_cmd_rm__run_loop:
  # Null ? End
  mov (%si), %al
  test %al, %al
  jz _cmd_rm__run_end

  # Init
  xor %al, %al
  mov %al, (%si)

  # Loop
  inc %si
  jmp _cmd_rm__run_loop

_cmd_rm__run_end:
  # Disk Write
  clc
  mov $0x43, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  #jc err_disk

  # Newline
  call newline

  # Return
  ret

# -----========== < Command (rm) ==========-----
# === < CODE
