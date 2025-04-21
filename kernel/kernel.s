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
  call read_key

  call hdl_kbd

  jmp .kernel_lp

# .init_cur() - init cursor
.init_cur:
  # prol
  push %bx

  call get_cursor

  # init {cur}
  mov %dl, (cur) # min
  mov %dl, (cur+1) # max

  # epil
  pop %bx
  ret

.section .data

kernel_prompt: .asciz "fayos:/# "

# cur [s_cur]
cur:
  .byte 0x00
  .byte 0x00

.kernel_ok_msg: .asciz "\nKernel ok\r\n"
.kernel_welcome_msg: .asciz "Welcome to Fayos kernel\r\n"
