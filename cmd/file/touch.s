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
# cmd_touch()

# DEPS
# cmd_touch()
#   read_block
#   write_block
#   write_dentry
#   print_newline
#   cli_buf_arg
#   cwd_lba
#   write_meta
#   free_lba

.code16
.section .text

.global cmd_touch

.extern read_block
.extern write_block
.extern write_dentry
.extern print_newline
.extern cli_buf_arg
.extern cwd_lba
.extern write_meta
.extern free_lba

# cmd_touch()
cmd_touch:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  movw (cwd_lba), %ax
  push %ax
  movw (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # set mem ptr
  mov $0x8000, %si

.cmd_touch__find_free_lp:
  # cond: null ? write_name
  mov (%si), %ax
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_touch__write_name

  # loop
  add $0x02, %si
  jmp .cmd_touch__find_free_lp

.cmd_touch__write_name:
  mov $cli_buf_arg, %di
  xor %cx, %cx

.cmd_touch__write_name_lp:
  # cond: null ? write_name_end
  mov (%di), %al # cli_buf_arg
  test %al, %al
  jz .cmd_touch__write_name_end

  # write mem
  mov %al, (%si)

  # loop
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp .cmd_touch__write_name_lp

.cmd_touch__write_name_end:
  # add null char
  add $0x01, %si # mem ptr
  add $0x01, %cx # name size

  # write dentry
  push %cx
  call write_dentry
  add $0x02, %sp

  # set data lba (dentry)
  mov (free_lba), %ax
  mov %ax, 4(%si)
  mov (free_lba+2), %ax
  mov %ax, 6(%si)

  call write_block

  # write meta !!! test
  call write_meta

  # allocate free lba, !!! low only, seq: write_meta
  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)

  call print_newline

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret
