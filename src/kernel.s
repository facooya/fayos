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

# === > PREVIEW

# DATA
# kernel_prompt

# === < PREVIEW
# ===
# === > CODE

.code16
.section .text

# FUNC
.global _start

# DATA
.global kernel_prompt
.global kernel_cur_min_x

# DEPS
.extern print_str # print.s
.extern kbd_disp # kbd.s
.extern master_block # disk.inc

# -== > Kernel Start

_start:
  # Out
  push $_kernel_load_msg
  call print_str
  add $0x02, %sp

  # Out
  push $_kernel_load_msg_2
  call print_str
  add $0x02, %sp

  # Newline
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10

  # Out
  push $kernel_prompt
  call print_str
  add $0x02, %sp

  # Master Block
  call master_block # disk.inc

  # Cursor
  call _kernel__cur_min_x_set

  # Set Buffer Raw
  call cli_buf_raw_set # cli_buf.s

# -== < Kernel Start
# ===
# -== > Kernel Loop

kernel_loop: # Main Loop
  # In
  mov $0x00, %ah # Read Key Press
  int $0x16

  # Keyboard
  call kbd_disp # kbd.s

  # Loop
  jmp kernel_loop

# -== < Kernel Loop

_kernel__cur_min_x_set:
  # Get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10 # Return: DH = y, DL = x

  # Set kernel_cur_min_x
  mov $kernel_cur_min_x, %si
  mov %dl, (%si)
  ret

# ===
# =============== > Include ===============
# !!! -T linker.ld, .global abcde

# -----========== > Library ==========-----

#.include "./inc/lib/print.inc"

# -----========== < Library ==========-----
# -----========== > System ==========-----

#.include "./inc/sys/kbd.inc"
#.include "./inc/sys/disk.inc"
#.include "./inc/sys/err.inc"

# -----========== < System ==========-----
# -----========== > Command ==========-----

# CLI (Command Line Interface)
#.include "./inc/cmd/cli_buf.inc"
#.include "./inc/cmd/cli_tok.inc"

# Command
#.include "./inc/cmd/cmd_table.inc"
#.include "./inc/cmd/cmd_exec.inc"

# System
.include "./inc/cmd/sys/clear.inc"
.include "./inc/cmd/sys/echo.inc"
.include "./inc/cmd/sys/help.inc"

# File
.include "./inc/cmd/file/touch.inc"
.include "./inc/cmd/file/ls.inc"
.include "./inc/cmd/file/rm.inc"
.include "./inc/cmd/file/cat.inc"

# -----========== < Command ==========-----
# =============== < Include ===============
# ===
# === < CODE
# ===
# === > Data

.section .data

# Message
_kernel_load_msg: .asciz "\nKernel Loaded\r\n"
_kernel_load_msg_2: .asciz "Fayos Kernel\r\n"

# Prompt
kernel_prompt: .asciz "fayos> "

# Cursor
kernel_cur_min_x: .byte 0x00

# === < Data


