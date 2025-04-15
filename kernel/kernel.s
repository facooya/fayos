# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Kernel for Fayos (docs/kernel/kernel.txt)

.code16
.section .text

.global _start
.global kernel_prompt
.global cur

.extern print_str
.extern print_newline
.extern hdl_kbd
.extern raw_buf
.extern init_super_block
.extern init_root_meta
.extern init_free_lba

# _start()
_start:
  call init_super_block
  call init_root_meta
  call init_free_lba

  push $.kernel_ok_msg
  call print_str
  add $0x02, %sp

  push $.kernel_welcome_msg
  call print_str
  add $0x02, %sp

  call print_newline

  push $kernel_prompt
  call print_str
  add $0x02, %sp

  mov $raw_buf, %si
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

# cur [s_cur]
cur:
  .byte 0x00
  .byte 0x00

.kernel_ok_msg: .asciz "\nKernel ok\r\n"
.kernel_welcome_msg: .asciz "Welcome to Fayos kernel\r\n"
