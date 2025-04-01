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
# write_meta_data() !!! test

# DEPS
# write_meta_data() !!! test
#   set_dap_lba
#   read_disk
#   write_disk
#   cli_cwd_lba_* !!! temp

# NOTE
# [common_dentry]
#   [dentry_variable]
#     [off-((name_size)+(padding_size))] name: 1-242 bytes (256 - [dentry_fixed])
#     [off-1] name_align: 0-1 byte
#
#   [dentry_fixed]
#     [off+0] magic_num: 2 bytes (0xFADE: FacooyA Directory Entry)
#     [off+2] name_size: 1 byte (for name)
#     [off+3] padding_size: 1 byte (for name_align)
#     [off+4] data_lba: 4 bytes (total)
#       [off+4] data_lba_low: 2 bytes (part of data_lba)
#       [off+6] data_lba_high: 2 bytes (part of data_lba)
#     !!! [off+8] parent_lba: 4 bytes (total)
#     !!!  [off+8] parent_lba_low: 2 bytes (part of parent_lba)
#     !!!  [off+10] parent_lba_high: 2 bytes (part of parent_lba)
#     [off+12] entry_level: 1 byte
#     [off+13] file_type: 1 byte
#   
#     (more: time)
#
#
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
.global write_meta_data # !!! test

.extern set_dap_lba
.extern read_disk
.extern write_disk
.extern dap
.extern cli_cwd_lba_low, cli_cwd_lba_high

# set_dentry(name_size) [n_set_dentry]
set_dentry:
  # prol
  push %bp
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
  movb $0x01, 12(%si) # entry level
  movb $0x0F, 13(%si) # file type

  # epil
  pop %dx
  pop %bx
  pop %ax
  pop %bp
  ret

# write meta data() !!! test
write_meta_data:
  # reverse reg_di
  mov (%di), %ax
  sub $0x08, %ax
  mov %ax, (%di)

  # set lba
  mov (%di), %ax # low
  push %ax
  mov 2(%di), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_disk

  # set ptr
  mov $0x8000, %si

  # write meta data
  mov (cli_cwd_lba_low), %ax # low
  mov %ax, (%si)
  mov (cli_cwd_lba_high), %ax # high
  mov %ax, 2(%si)
  mov $0xFADA, 4(%si) # magic

  call write_disk

  ret
