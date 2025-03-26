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

# NOTE
# - kernel LBA: 0x20-0x4F
# - kernel mem: 0x1000-0x6FFF

# DEPS
# _start()
# - print_str
# - master_block
# - cli_buf_raw_set
#
# kernel_loop()
# - hdl_kbd

.code16
.section .text

.global _start
.global kernel_prompt
.global kernel_min_cur_pos_x

.extern print_str
.extern hdl_kbd
.extern master_block
.extern cli_buf_raw_set

# _start()
_start:
  push $.kernel_ok_str
  call print_str
  add $0x02, %sp

  push $.kernel_welcome_str
  call print_str
  add $0x02, %sp

  # newline
  mov $0x0E, %ah
  mov $0x0D, %al # carriage return
  int $0x10
  mov $0x0A, %al # line feed
  int $0x10

  push $kernel_prompt
  call print_str
  add $0x02, %sp

  call master_block

  call cli_buf_raw_set # set_cli_buf_raw !!!
  call .set_kernel_min_cur_pos_x

# kernel_loop()
kernel_loop:
  # in
  mov $0x00, %ah
  int $0x16

  call hdl_kbd
  jmp kernel_loop

# set_kernel_minimum_cursor_position_x()
.set_kernel_min_cur_pos_x:
  # reg_si = cli_buf_raw
  # prol
  push %si
  push %ax
  push %bx
  push %dx

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # reg_dl = x (current)
  # set kernel_min_cur_pos_x
  mov $kernel_min_cur_pos_x, %si
  mov %dl, (%si)

  # epil
  pop %dx
  pop %bx
  pop %ax
  pop %si
  ret

# System !!! Temporary
.include "./cmd/sys/clear.inc"
.include "./cmd/sys/echo.inc"
.include "./cmd/sys/help.inc"

# File !!! Temporary
.include "./cmd/file/touch.inc"
.include "./cmd/file/ls.inc"
.include "./cmd/file/rm.inc"
.include "./cmd/file/cat.inc"


.section .data

kernel_prompt: .asciz "fayos:/# "
kernel_min_cur_pos_x: .byte 0x00

.kernel_ok_str: .asciz "\nKernel ok\r\n"
.kernel_welcome_str: .asciz "Welcome to fayos kernel\r\n"
