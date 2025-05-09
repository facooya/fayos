# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate

.equ DENT_I_NUM_LO_OFF, 0x00
.equ DENT_I_NUM_HI_OFF, 0x02
.equ DENT_REC_LEN_OFF, 0x04

.section .text
.code16

.global alloc_dentry

# ENTRY
# alloc_dentry()
#   pre: bx = main mem ptr
alloc_dentry:
  # prol
  push %bx

.alloc_dentry__lp:
  # load
  mov DENT_I_NUM_LO_OFF(%bx), %ax

  # cond: null ? end
  test %ax, %ax
  or DENT_I_NUM_HI_OFF(%bx), %ax
  jz .alloc_dentry__end

  # step
  mov DENT_REC_LEN_OFF(%bx), %cx
  add %cx, %bx
  jmp .alloc_dentry__lp

.alloc_dentry__end:
  # set
  mov %bx, (dentry_ptr)

  # epil
  pop %bx
  ret
