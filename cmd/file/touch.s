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
#   rw_disk
#   set_dentry
#   print_newline
#   master_dap
#   cli_buf_arg
#   cli_cwd_lba

.code16
.section .text

.global cmd_touch

.extern rw_disk
.extern set_dentry
.extern print_newline
.extern master_dap
.extern cli_buf_arg
.extern cli_cwd_lba

# cmd_touch()
cmd_touch:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  push $0x00
  # push $0x80 # !!! root dir
  mov (cli_cwd_lba), %ax # !!! test
  push %ax # !!! test
  call set_dap_lba
  add $0x04, %sp

  # read disk
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

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

  # set dentry
  push %cx
  call set_dentry
  add $0x02, %sp

  # read disk (master)
  push $master_dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  # set mem ptr
  mov $0x0600, %di

  # get lba (master), set lba (dentry)
  mov (%di), %ax # low
  mov %ax, 4(%si)
  mov 2(%di), %ax # high
  mov %ax, 6(%si)

  # write next block num
  mov (%di), %ax
  add $0x08, %ax
  mov %ax, (%di)

  # write disk (master)
  push $master_dap
  push $0x43
  call rw_disk
  add $0x04, %sp

  # write disk
  push $dap
  push $0x43
  call rw_disk
  add $0x04, %sp

  call print_newline

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret
