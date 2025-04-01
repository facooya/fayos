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
# cmd_cat()

# DEPS
# cmd_cat()
#   print_newline
#   rw_disk
#   set_dap_lba

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

.global cmd_cat

.extern print_newline
.extern rw_disk
.extern set_dap_lba

# cmd_cat()
cmd_cat:
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

  call print_newline

  # set mem ptr
  mov $0x8000, %si

.cmd_cat__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_cat__cmp_name

  # cond: null ? done
  mov (%si), %ax
  or 2(%si), %ax
  jz .cmd_cat__done

  # loop
  add $0x02, %si
  jmp .cmd_cat__find_magic_lp

.cmd_cat__cmp_name:
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

.cmd_cat__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_cat__main

  # cond: char != ? skip_dentry
  mov (%si), %al # cli_buf_arg
  cmp (%di), %al # name ptr
  jne .cmd_cat__skip_dentry

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_cat__cmp_name_lp

.cmd_cat__skip_dentry:
  pop %si # main mem ptr

  # !!! temp
  mov $0x0E, %ah
  mov $'N', %al
  int $0x10

  # skip dentry [n_skip_dentry]
  add $0x0A, %si

  # loop
  jmp .cmd_cat__find_magic_lp

.cmd_cat__main:
  pop %si # main mem ptr

  # !!! temp
  mov $0x0E, %ah
  mov $'M', %al
  int $0x10

  # cond: 1 != ? done
  # !!! temp, only entry level 1
  mov 12(%si), %al # entry level
  cmp $0x01, %al
  jnz .cmd_cat__done

  # set lba
  mov 4(%si), %ax # low
  push %ax
  mov 6(%si), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp
  
  # read disk
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  # set data mem ptr
  mov $0x8000, %si

  mov $0x0E, %ah

.cmd_cat__out_data:
  # cond: null ? done
  movb (%si), %al
  test %al, %al
  jz .cmd_cat__done

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .cmd_cat__out_data

.cmd_cat__done:
  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret
