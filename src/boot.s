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
# [n_cli]
# - Fayos does not use IRQ in x86-16 mode
#
# [n_init]
# - skip init (CS, SI, DI, IP)
# - CS = 0x07C0, IP = 0x0000
# - calc: (CS * 16) + IP = 0x7C00
# 
# [n_stack]
# - SP: 0x7C00 (stack start)
# - memory: 0x7000-0x7BFF
# - max: 1546 stacks
#
# [n_dap]
# - for kernel
# - sector count: 0x30
# - IP: 0x1000, CS: 0x0000
# - LBA: 0x20
#
# [n_end]
# - boot sector: 0x7C00-0x7DFF
# - magic number: .word 0xAA55 (little endian)
# - .word 0xAA55 == .byte 0x55, 0xAA

.code16
.global _start

# _start()
_start:
  cli # [n_cli]

  # init [n_init]
  xor %ax, %ax
  mov %ax, %ds
  mov %ax, %es
  mov %ax, %ss
  mov %ax, %bx
  mov %ax, %cx
  mov %ax, %dx
  mov %ax, %bp

  # set stack [n_stack]
  mov $0x7C00, %sp

  push $.os_name_str
  call .out_str
  add $0x02, %sp

  # for kernel
  call .read_disk
  ljmp $0x0000, $0x1000

# .read_disk()
.read_disk:
  clc
  mov $0x42, %ah
  mov $0x80, %dl
  mov $.dap, %si
  int $0x13
  jc .hdl_disk_err

  push $.disk_ok_str
  call .out_str
  add $0x02, %sp

  ret

# .handler_disk_error
.hdl_disk_err:
  push $.disk_err_str
  call .out_str
  add $0x02, %sp

  hlt

# .out_string(str)
.out_str:
  # prol
  push %bp
  mov %sp, %bp
  mov 4(%bp), %si

  mov $0x0E, %ah

.out_str_lp:
  # cond
  mov (%si), %al
  test %al, %al
  jz .out_str_done

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .out_str_lp

.out_str_done:
  # epil
  pop %bp
  ret

# str
.os_name_str: .asciz "\nFAYOS\r\n"
.disk_ok_str: .asciz "Disk ok\r\n"
.disk_err_str: .asciz "Disk err\r\n"

# dap [n_dap]
.dap:
  .byte 0x10
  .byte 0x00
  .word 0x30
  .word 0x1000
  .word 0x0000
  .word 0x20
  .word 0x00
  .word 0x00
  .word 0x00

# end [n_end]
.fill 0x01FE-(.-_start), 0x01, 0x00
.word 0xAA55
