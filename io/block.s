# SPDX-License-Identifier: GPL-3.0-or-later
#
# Block read/write and DAP setup (docs/io/block.txt)
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

.code16
.section .text

.global set_dap_lba
.global set_dap_target
.global reset_dap_target
.global read_block
.global write_block
.global dap

.extern print_newline
.extern print_str

# set_dap_lba(lba_high, lba_low) [n_set_dap]
set_dap_lba:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # set lba
  mov $dap, %si
  mov 4(%bp), %ax # high
  mov %ax, 10(%si)
  mov 6(%bp), %ax # low
  mov %ax, 8(%si)
  
  # epli
  pop %ax
  pop %si
  pop %bp
  ret

# set_dap_target(count, segment, offset) [n_set_dap]
set_dap_target:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # set dap target
  mov $dap, %si
  mov 4(%bp), %ax
  mov %ax, 2(%si) # count
  mov 6(%bp), %ax
  mov %ax, 6(%si) # segment
  mov 8(%bp), %ax
  mov %ax, 4(%si) # offset

  # epli
  pop %ax
  pop %si
  pop %bp
  ret

# reset_dap_target()
reset_dap_target:
  push $0x8000
  push $0x00
  push $0x08
  call set_dap_target
  add $0x06, %sp
  ret

# read_block()
read_block:
  push $0x42
  call .rw_block
  add $0x02, %sp
  ret

# write_block()
write_block:
  push $0x43
  call .rw_block
  add $0x02, %sp
  ret

# .rw_block(mode) [n_rw_block]
.rw_block:
  # prol
  push %bp
  mov %sp, %bp
  push %ax
  push %dx
  push %si

  # try
  clc
  mov 4(%bp), %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc .rw_block__err

.rw_block__done:
  # epil
  pop %si
  pop %dx
  pop %ax
  pop %bp
  ret

.rw_block__err:
  call print_newline

  push $.block_err_msg
  call print_str
  add $0x02, %sp

  call print_newline

  jmp .rw_block__done

.section .data

# dap [n_dap]
dap:
  .byte 0x10
  .byte 0x00
  .word 0x08
  .word 0x8000
  .word 0x00
  .word 0x80
  .word 0x00 
  .word 0x00
  .word 0x00

# msg
.block_err_msg: .asciz "Block error."
