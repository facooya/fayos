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

.global _start
.global kernel_prompt

.extern print_str, print_esc # print.s
.extern keyboard_manager, newline, set_cursor_min_x # kbd.s
.extern master_block # disk.inc

# -== > Kernel Start

_start:
  # Print Load Message
  push $_kernel_load_msg
  call print_str
  add $0x02, %sp

  # Print Load Message 2
  push $_kernel_load_msg_2
  call print_str
  add $0x02, %sp

  call newline # kbd.s

  # Print Prompt
  push $kernel_prompt
  call print_str
  add $0x02, %sp

  # Master Block
  call master_block # disk.inc

  # Cursor
  call set_cursor_min_x # kbd.s

  # Set Buffer Raw
  call cli_buf_raw_set # cli_buf.s

# -== < Kernel Start
# ===
# -== > Kernel Loop

kernel_loop: # Main Loop
  mov $0x00, %ah # Read Key Press
  int $0x16

  # Keyboard, Command
  call key_manager # kbd.s

  # Loop
  jmp kernel_loop

# -== < Kernel Loop
# ===
# =============== > Include ===============
# !!! -T linker.ld, .global abcde

# -----========== > Library ==========-----

#.include "./inc/lib/print.inc"

# -----========== < Library ==========-----
# -----========== > System ==========-----

#.include "./inc/sys/kbd.inc"
.include "./inc/sys/disk.inc"
.include "./inc/sys/err.inc"

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

_kernel_load_msg: .asciz "\nKernel Loaded\r\n"
_kernel_load_msg_2: .asciz "Fayos Kernel\r\n"
kernel_prompt: .asciz "fayos> "

# === < Data


