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
# cmd_ls()

# DEPS
# cmd_ls()
#   set_dap_lba
#   rw_disk
#   print_newline

# NOTE
# [n_skip_dentry]
#   2 (magic num)
#   + 1 (name size)
#   + 1 (padding size)
#   + 4 (block entry)
#   + 1 (entry level)
#   + 1 (file type)
#   = 10 = 0x0A

.code16
.section .text

.global cmd_ls

.extern rw_disk
.extern print_newline

# cmd_ls() !!! current dir
cmd_ls:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # set lba
  push $0x00
  push $0x80 # root dir
  call set_dap_lba
  add $0x04, %sp

  # read disk
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  call print_newline

  # set mem ptr
  mov $0x8000, %si

.cmd_ls__find_magic_lp:
  # cond: magic ? chk_del
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_ls__chk_del

  # cond: null ? done
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_ls__done

  # loop
  add $0x02, %si
  jmp .cmd_ls__find_magic_lp

.cmd_ls__chk_del:
  # cond: bit ? chk_del_end
  xor %ax, %ax
  mov 9(%si), %al # file type
  bt $0x07, %ax
  jc .cmd_ls__chk_del_end

  # default
  jmp .cmd_ls__read_name

.cmd_ls__chk_del_end:
  # loop
  add $0x0A, %si # [n_skip_dentry]
  jmp .cmd_ls__find_magic_lp

.cmd_ls__read_name:
  # copy mem ptr
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set name ptr
  sub %cx, %di

  mov $0x0E, %ah

.cmd_ls__read_name_lp:
  # cond: null ? read_name_end
  mov (%di), %al
  test %al, %al
  jz .cmd_ls__read_name_end

  # out
  int $0x10

  # loop
  add $0x01, %di
  jmp .cmd_ls__read_name_lp

.cmd_ls__read_name_end:
  # skip dentry [n_skip_dentry]
  add $0x0A, %si
 
  # division
  mov $0x20, %al # space
  int $0x10
  int $0x10
  
  # loop
  jmp .cmd_ls__find_magic_lp

.cmd_ls__done:
  call print_newline
  
  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret
