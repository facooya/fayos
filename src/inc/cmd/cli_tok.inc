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

# === > CODE

.code16

# -== > CLI Tokenizer

cli_tok:
_cli_tok__prol:



_cli_tok__epli:
_cli_tok__done:
  ret

# -== < CLI Tokenizer

# =============== > Parse Key Buffer

parse_key_buf: # Entry Point
  mov $key_buf, %si # Main Buffer
  jmp parse_key_buf_cmd

# ==========----- > Parse Command -----==========
# !!! Verify First is Char OR Number

parse_key_buf_cmd:
  mov $cmd_buf, %di

parse_key_buf_cmd_loop:
  # Compare Null
  mov (%si), %al
  test %al, %al
  jz parse_key_buf_cmd_done

  # Compare Space
  cmp $0x20, %al
  jz parse_verify_key_buf_opt # Parse opt => arg

  # Save cmd_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp parse_key_buf_cmd_loop

parse_key_buf_cmd_done:
  # Add Null
  xor %al, %al
  mov %al, (%di)

  # Return
  ret

# ==========----- < Parse Command -----==========
# ==========----- > Parse Option -----==========

# =====---------- > Verify Option ----------=====

parse_verify_key_buf_opt:
  # [SI]: Space, [SI+1]: Hyphen-Minus OR Argument Byte
  inc %si

  # Compare Hyphen-Minus
  mov (%si), %al
  cmp $0x2D, %al
  jz parse_key_buf_opt

  # Not Option
  jmp parse_key_buf_arg

# =====---------- < Verify Option ----------=====
# Opt: -a -b -c, -abc = opt_buf: abc
parse_key_buf_opt:
  # [SI]: Hyphen-Minus, [SI+1]: Option Byte
  inc %si
  mov $opt_buf, %di

parse_key_buf_opt_loop:
  # Compare Null, Error => Exit
  mov (%si), %al
  test %al, %al
  jz parse_key_buf_opt_exit

  # Compare Space, Safe => Done => Next
  mov (%si), %al
  cmp $0x20, %al
  jz parse_verify_key_buf_opt_is_opt # Check Point 

  # Save: opt_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp parse_key_buf_opt_loop

parse_verify_key_buf_opt_is_opt:
  # [SI]: Space, [SI+1]: Hyphen-Minus OR Argument Byte
  inc %si

  # Compare Hyphen-Minus
  mov (%si), %al
  cmp $0x2D, %al
  jz parse_verify_key_buf_opt_true

  # Next Point, Option Done
  jmp parse_key_buf_opt_done # Next Point

parse_verify_key_buf_opt_true:
  # [SI]: Hyphen-Minus, [SI+1]: Option Byte
  # [DI](opt_buf): Already Empty Byte

  # Continue Loop
  inc %si
  jmp parse_key_buf_opt_loop

parse_key_buf_opt_exit:
  call init_opt_buf
  ret

parse_key_buf_opt_done:
  # Add Null Byte: (opt_buf) + (Null)
  xor %al, %al
  mov %al, (%di)

  # Next Point
  jmp parse_key_buf_arg

# ==========----- < Parse Option -----==========
# ------------------------------

parse_key_buf_arg:
  #inc %si # save_opt_buf_done
  mov $arg_buf, %di

parse_key_buf_arg_loop:
  # Compare Null
  mov (%si), %al
  test %al, %al
  jz parse_key_buf_arg_done

  # Save arg_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp parse_key_buf_arg_loop

parse_key_buf_arg_done:
  #PRINT arg_buf # print.inc

  #jmp parse_key_buf_done
  ret

# =============== < Seperate Key Buffer ===============

# =============== < CODE ===============
