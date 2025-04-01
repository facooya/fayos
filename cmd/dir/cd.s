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
# cmd_cd()

# DEPS
# cmd_cd()
#   set_dap_lba
#   read_disk
#   dap
#   cli_cwd_lba_*
#   cli_buf_arg

.code16
.section .text

.global cmd_cd

.extern print_newline
.extern set_dap_lba
.extern read_disk
.extern dap
.extern cli_cwd_lba_low, cli_cwd_lba_high
.extern cli_buf_arg

# cmd_cd()
cmd_cd:
  # prol

  # cond: period ? back !!! test
  mov $cli_buf_arg, %di
  mov (%di), %ax
  cmp $0x2E2E, %ax # period
  jz .cmd_cd__back

  # set lba
  mov (cli_cwd_lba_low), %ax
  push %ax
  mov (cli_cwd_lba_high), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_disk

  # set mem ptr
  mov $0x8000, %si

.cmd_cd__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_cd__cmp_name

  # cond: null ? done
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_cd__done

  # loop
  add $0x02, %si
  jmp .cmd_cd__find_magic_lp

.cmd_cd__cmp_name:
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

.cmd_cd__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_cd__main

  # cond: char != ? cmp_name_end
  mov (%si), %al # cli_buf_arg
  cmp (%di), %al # name ptr
  jne .cmd_cd__cmp_name_end

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_cd__cmp_name_lp

.cmd_cd__cmp_name_end:
  pop %si # main mem ptr

  # loop
  add $0x0A, %si # cat.s [n_skip_dentry]
  jmp .cmd_cd__find_magic_lp

.cmd_cd__main:
  pop %si # main mem ptr

  mov $0x0E, %ah
  mov $'M', %al
  int $0x10

  # get data lba (dentry), set lba (cli_cwd_lba_*)
  mov 4(%si), %ax # low
  mov %ax, (cli_cwd_lba_low)
  mov 6(%si), %ax # high
  mov %ax, (cli_cwd_lba_high)

.cmd_cd__done:
  call print_newline

  # epil
  ret

.cmd_cd__back:
  mov $0x0E, %ah
  mov $'A', %al
  int $0x10

  # !!! meta_data
  # set meta lba
  mov (cli_cwd_lba_low), %ax
  push %ax
  mov (cli_cwd_lba_high), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_disk

  # set mem ptr
  mov $0x8000, %si

  # get parent lba (dentry !!! mata_data), set lba (cli_cwd_lba_*)
  mov (%si), %ax # low
  mov %ax, (cli_cwd_lba_low)
  mov 2(%si), %ax # high
  mov %ax, (cli_cwd_lba_high)

  jmp .cmd_cd__done
