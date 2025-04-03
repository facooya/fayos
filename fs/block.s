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
# init_master_block()
#
# .init_root_meta_data() !!! test

# DEPS
# init_master_block()
#   set_dap_target
#   reset_dap_target
#   set_dap_lba
#   read_disk
#   write_disk
#   dap
#
# .init_root_meta_data() !!! test
#   set_dap_lba
#   dap

# NOTE
# 0x10: master
#   0x00: next LBA
#   0x04: root LBA
# 0x80: root
# 
# [meta_data]
#   parent_lba: 4 bytes
#     parent_lba_low: 2 bytes
#     parent_lba_high: 2 bytes
#   magic_num: 2 bytes (0xFADA: FacooyA meta DatA)

.code16
.section .text

.global init_master_block

.extern set_dap_lba
.extern set_dap_target
.extern reset_dap_target
.extern read_disk
.extern write_disk
.extern dap

# init_master_block()
init_master_block:
  push %si
  push %ax

  # set target (master)
  push $0x0600
  push $0x00
  push $0x04
  call set_dap_target
  add $0x06, %sp

  # set lba
  push $0x10
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_disk

  # set mem ptr
  mov $0x0600, %si

  # cond: null != ? done
  mov (%si), %ax
  or 2(%si), %ax
  jnz .init_master_block__done

  # write mem !!! change 4 bytes
  mov $0x88, %ax # next
  mov %ax, (%si)

  call write_disk

  call reset_dap_target

  # set lba
  push $0x80
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  # init root meta data
  call .init_root_meta_data

.init_master_block__done:
  pop %ax
  pop %si
  ret

.init_root_meta_data:
  # set meta lba
  push $0x80 # root dir
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_disk

  # set mem ptr
  mov $0x8000, %si

  # write meta data
  movw $0x80, (%si) # low
  movw $0x00, 2(%si) # high
  movw $0xFADA, 4(%si) # magic

  call write_disk
  ret

  