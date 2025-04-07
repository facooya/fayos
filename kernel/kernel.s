# SPDX-License-Identifier: GPL-3.0-or-later
#
# Kernel for Fayos (docs/kernel/kernel.txt)
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

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
  call .init_cur

# .kernel_lp() - main loop
.kernel_lp:
  # read
  mov $0x00, %ah
  int $0x16

  call hdl_kbd

  jmp .kernel_lp

# .init_cur() - init cursor
.init_cur:
  # prol
  push %ax
  push %bx
  push %cx
  push %dx

  # get {cur}
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # init {cur}
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
