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
# _start()
# kernel_loop()
# kernel_prompt
# cur
#
# .set_cur()

# DEPS
# _start()
# - print_str
# - print_newline
# - init_master_block
# - cli_buf_raw
#   set_free_lba
#
# kernel_loop()
# - hdl_kbd

# NOTE
# - kernel LBA: 0x20-0x4F
# - kernel mem: 0x1000-0x6FFF

.code16
.section .text

.global _start
.global kernel_prompt
.global cur

.extern print_str
.extern print_newline
.extern hdl_kbd
.extern init_master_block
.extern cli_buf_raw
.extern set_free_lba

# _start()
_start:
  push $.kernel_ok_str
  call print_str
  add $0x02, %sp

  push $.kernel_welcome_str
  call print_str
  add $0x02, %sp

  call print_newline

  push $kernel_prompt
  call print_str
  add $0x02, %sp

  call init_master_block
  call set_free_lba

  mov $cli_buf_raw, %si
  call .set_cur

# kernel_loop() - main loop
kernel_loop:
  # in
  mov $0x00, %ah
  int $0x16

  call hdl_kbd
  jmp kernel_loop

# .set_cur() - set cursor
.set_cur:
  # prol
  push %ax
  push %bx
  push %cx
  push %dx

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # set min {cur}
  mov %dl, (cur) # min
  mov %dl, (cur+1) # max

  # epil
  pop %dx
  pop %cx
  pop %bx
  pop %ax
  ret


.section .data

kernel_prompt: .asciz "fayos:/# "
cur:
  .byte 0x00 # min pos x
  .byte 0x00 # max pos x

.kernel_ok_str: .asciz "\nKernel ok\r\n"
.kernel_welcome_str: .asciz "Welcome to fayos kernel\r\n"
