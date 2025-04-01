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
.extern rw_disk
.extern dap

# cmd_rm()
cmd_rm:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  push $0x80 # !!! root dir
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  # read disk
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  # set mem ptr
  mov $0x8000, %si

.cmd_rm__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_rm__cmp_name

  # cond: null ? done
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_rm__done

  # loop
  add $0x02, %si
  jmp .cmd_rm__find_magic_lp

.cmd_rm__cmp_name:
  # copy ptr (magic)
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # setup
  push %si # main mem ptr
  mov $cli_buf_arg, %si

.cmd_rm__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_rm__main

  # cond: char != ? skip_dentry
  mov (%si), %al # cli_buf_arg
  cmp (%di), %al # name ptr
  jne .cmd_rm__skip_dentry

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_rm__cmp_name_lp

.cmd_rm__skip_dentry:
  pop %si # main mem ptr

  # loop
  add $0x0A, %si # cat.s [n_skip_dentry]
  jmp .cmd_rm__find_magic_lp

.cmd_rm__main:
  pop %si # main mem ptr

  # bit test set
  xor %ax, %ax
  bts $0x07, %ax # msb
  mov %al, 13(%si) # file type

  # write disk
  push $dap
  push $0x43
  call rw_disk
  add $0x04, %sp

.cmd_rm__done:
  call print_newline

  # epil
  pop %ax
  pop %cx
  pop %di
  pop %si
  ret

# -----========== < Command (rm) ==========-----
# === < CODE
