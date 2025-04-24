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
  call puts
  add $0x02, %sp

  push $.kernel_welcome_msg
  call puts
  add $0x02, %sp

  call outnl

  push $kernel_prompt
  call puts
  add $0x02, %sp

  call init_cursor
  mov $raw_buf, %si

# .kernel_lp() - main loop
.kernel_lp:
  call sys_read_key

  call hdl_kbd

  jmp .kernel_lp

.section .data

kernel_prompt: .asciz "fayos:/# "
.kernel_ok_msg: .asciz "\nKernel ok\r\n"
.kernel_welcome_msg: .asciz "Welcome to Fayos kernel\r\n"
