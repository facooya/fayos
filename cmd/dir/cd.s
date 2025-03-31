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
#   rw_disk
#   dap
#   cli_cwd_lba
#   cli_buf_arg

.code16
.section .text

.global cmd_cd

.extern print_newline
.extern set_dap_lba
.extern rw_disk
.extern dap
.extern cli_cwd_lba
.extern cli_buf_arg

# cmd_cd()
cmd_cd:
  # prol

  # cond: period ? back
  mov $cli_buf_arg, %di
  mov (%di), %ax
  cmp $0x2E2E, %ax # period
  jz .cmd_cd__back

  # set lba
  mov (cli_cwd_lba+2), %ax
  push %ax
  mov (cli_cwd_lba), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read disk
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

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

  # get lba (dentry), set lba (cli_cwd_lba)
  mov 4(%si), %ax # low
  mov %ax, (cli_cwd_lba)
  mov 6(%si), %ax # high
  mov %ax, (cli_cwd_lba+2)

.cmd_cd__done:
  call print_newline
  # cmp name
  # main change cli_cwd_lba

  # epil
  ret

.cmd_cd__back:
  mov $0x0E, %ah
  mov $'A', %al
  int $0x10

  # get parent lba (dentry), set lba (cli_cwd_lba)
  mov 8(%si), %ax # low
  mov %ax, (cli_cwd_lba)
  mov 10(%si), %ax # high
  mov %ax, (cli_cwd_lba+2)

  jmp .cmd_cd__done
