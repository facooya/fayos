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
.global cmd_clear

# -----========== > Command Clear ==========-----

cmd_clear:
  # Get Cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10 # [DH] => [DH](Y2)

  # Get Video Mode
  mov $0x0F, %ah # return X => [AH]
  int $0x10
  mov %ah, %dl # videoX => [DL](X2)

  # Scroll Up
  mov $0x06, %ah # Scroll Up
  mov $0x00, %al # Scroll Lines, 0x00: Clear
  mov $0x07, %bh # [BH] = (BG[4-bits] << 4) + FG[4-bits], 0x0: Black, 0x7: Light Gray
  mov $0x00, %ch # Y1
  mov $0x00, %cl # X1
  #mov $0x00, %dh # Y2
  #mov $0x00, %dl # X2
  int $0x10

  # Set Cursor
  mov $0x02, %ah
  mov $0x00, %bh
  mov $0x00, %dh
  mov $0x00, %dl
  int $0x10

  # Return
  ret

# -----========== < Command Clear ==========-----
# === < CODE
