# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Cursor library

.code16
.section .text

.global get_cursor
.global set_cursor
.global init_cursor
.global cursor

# ENTRY
# get_cursor()
# ret: dh = y
# ret: dl = x
get_cursor:
  push %bx
  call sys_get_cursor
  pop %bx
  ret

# ENTRY
# set_cursor()
# pre: dh = y
# pre: dl = x
set_cursor:
  push %bx
  call sys_set_cursor
  pop %bx
  ret

# ENTRY
# init_cursor()
init_cursor:
  push %bx
  call sys_get_cursor

  mov %dl, (cursor)
  mov %dl, (cursor+2)

  pop %bx
  ret

.section .data

cursor: # docs/kernel/kernel.txt [s_cur]
  .word 0x00 # min
  .word 0x00 # max
