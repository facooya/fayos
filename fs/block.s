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

# DEPS
# init_master_block()
#   rw_disk
#   master_dap
#   cli_cwd_lba

# NOTE
# 0x10: master
#   0x00: next LBA
#   0x04: root LBA
# 0x80: root

.code16
.section .text

.global init_master_block

.extern rw_disk
.extern master_dap
.extern cli_cwd_lba

# init_master_block()
init_master_block:
  push %si
  push %ax

  # read disk
  push $master_dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  # set mem ptr
  mov $0x0600, %si

  # cond: null != ? done
  mov (%si), %ax
  or 2(%si), %ax
  jnz .init_master_block__done

  # write mem !!! change 4 bytes
  mov $0x88, %ax # next
  mov %ax, (%si)
  mov $0x80, %ax # root
  mov %ax, 4(%si)
  mov %ax, (cli_cwd_lba) # set

  # write disk
  push $master_dap
  push $0x43
  call rw_disk
  add $0x04, %sp

.init_master_block__done:
  pop %ax
  pop %si
  ret
  