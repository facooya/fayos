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
# set_dentry()

# NOTE
# [common_file_type]
#   0x0D: dir, 0x0E: exec, 0x0F: file 
#   MSB 1 is deleted. file_type << 7 == 1 ? deleted
#   E.g., 0x0F (file) + 0x80 = 0x8F (deleted file)
# 
# [n_set_dentry]
#   align: name_size % 2 = DL, SI += DL
#     SI: mem ptr (magic num)
#     padding size: 3(SI) = DL

.code16
.section .text

.global set_dentry

# set_dentry(name_size) [n_set_dentry]
set_dentry:
  # prol
  push %sp
  mov %sp, %bp
  push %ax
  push %bx
  push %dx

  # div for align
  mov 4(%bp), %ax
  mov $0x02, %bx
  xor %dx, %dx
  div %bx

  # dentry magic
  add %dx, %si # mem align
  movw $0xFADE, (%si) # magic: FacooyA Directory Entry

  # dentry name
  mov 4(%bp), %al
  mov %al, 2(%si) # name size
  mov %dl, 3(%si) # name align

  # dentry etc
  movb $0x01, 8(%si) # entry level
  movb $0x0F, 9(%si) # file type

  # epil
  pop %dx
  pop %bx
  pop %ax
  pop %bp
  ret
