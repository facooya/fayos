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
# cmd_rm()

# DEPS
# cmd_rm()
#   print_newline
#   rw_disk
#   dap

.code16
.section .text

.global cmd_rm

.extern print_newline
.extern dap
.extern rw_disk

# cmd_rm()
cmd_rm:
  # !!! remove arg
  # prol
  push %si
  push %ax

  # set lba
  push $0x00
  push $0x80 # !!! root dir
  call set_dap_lba
  add $0x04, %sp

  # read disk
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  # set mem ptr
  mov $0x8000, %si

.cmd_rm__lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .cmd_rm__done

  # init
  xor %al, %al
  mov %al, (%si)

  # loop
  add $0x01, %si
  jmp .cmd_rm__lp

.cmd_rm__done:
  # write disk
  push $dap
  push $0x43
  call rw_disk
  add $0x04, %sp

  call print_newline

  # epil
  pop %ax
  pop %si
  ret

# -----========== < Command (rm) ==========-----
# === < CODE
