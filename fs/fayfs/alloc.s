# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate

.include "fayfs/de.s"

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
  mov DE_I_NUM_LO_OFF(%bx), %ax

  # cond: null ? end
  test %ax, %ax
  or DE_I_NUM_HI_OFF(%bx), %ax
  jz .alloc_dentry__end

  # step
  mov DE_REC_LEN_OFF(%bx), %cx
  add %cx, %bx
  jmp .alloc_dentry__lp

.alloc_dentry__end:
  # set
  sub $0x8000, %bx
  mov %bx, (dentry_ptr)

  # epil
  pop %bx
  ret
