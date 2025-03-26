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

# FUNC
# cli_tok()

# DEPS
# /src/inc/cmd/cli_buf.inc (
#   FUNC: cli_buf_raw_set
#   DATA: cli_buf_cmd, cli_buf_opt, cli_buf_arg
# )

# === < PREVIEW
# === > CODE

.code16
.section .text

.global cli_tok

.extern cli_buf_raw_set # cli_buf.s
.extern cli_buf_cmd, cli_buf_opt, cli_buf_arg # cli_buf.s

# -== > CLI Tokenizer

cli_tok:
_cli_tok__prol:
  call cli_buf_raw_set

# --= > Buffer Command

_cli_tok__buf_cmd_set:
  mov $cli_buf_cmd, %di

_cli_tok__buf_cmd_lp:
  # Cond: null ? buf_cmd_exit
  mov (%si), %al # SI: cli_buf_raw
  test %al, %al
  jz _cli_tok__buf_cmd_exit

  # Cond: space ? buf_cmd_end
  cmp $0x20, %al # 0x20: SPACE
  jz _cli_tok__buf_cmd_end

  # Save
  mov %al, (%di) # DI: cli_buf_cmd

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cli_tok__buf_cmd_lp

_cli_tok__buf_cmd_end:
  # SI: Space, SI+1: Hyphen-Minus || Argument
  add $0x01, %si

  # Cond: !Hyphen-Minus ? buf_opt_end
  mov (%si), %al
  cmp $0x2D, %al # 0x2D: Hyphen-Minus
  jne _cli_tok__buf_opt_end

  # Else: buf_opt_set

# --= < Buffer Command
# ===
# --= > Buffer Option

_cli_tok__buf_opt_set:
  # SI: Hyphen-Minus, SI+1: Option
  add $0x01, %si
  mov $cli_buf_opt, %di

_cli_tok__buf_opt_lp:
  # Cond: null ? buf_opt_exit
  mov (%si), %al
  test %al, %al
  jz _cli_tok__buf_opt_exit

  # Cond: space ? buf_opt_chk
  mov (%si), %al
  cmp $0x20, %al # 0x20: Space
  je _cli_tok__buf_opt_chk

  # Save
  mov %al, (%di) # DI: cli_buf_opt

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cli_tok__buf_opt_lp

_cli_tok__buf_opt_chk:
  # SI: space, SI+1: hyphen-minus || argument
  add $0x01, %si

  # Cond: !hyphen-minus ? buf_opt_end
  mov (%si), %al
  cmp $0x2D, %al # 0x2D: hyphen-minus
  jne _cli_tok__buf_opt_end

  # Else: continue
  # SI: hyphen-minus, SI+1: option
  add $0x01, %si
  jmp _cli_tok__buf_opt_lp

_cli_tok__buf_opt_end:
  # SI: argument

# --= < Buffer Option
# ===
# --= > Buffer Argument

_cli_tok__buf_arg_set:
  mov $cli_buf_arg, %di

_cli_tok__buf_arg_lp:
  # Cond: null ? buf_arg_end
  mov (%si), %al
  test %al, %al
  jz _cli_tok__buf_arg_end

  # Save
  mov %al, (%di) # DI: cli_buf_arg

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cli_tok__buf_arg_lp

_cli_tok__buf_arg_end:
  # SI: null

# --= < Buffer Argument

_cli_tok__epli:
_cli_tok__done:
  ret

_cli_tok__buf_cmd_exit: # !!! Temporary
  xor %al, %al
  mov %al, (%di)

  ret

_cli_tok__buf_opt_exit: # !!! Temporary
  xor %al, %al
  mov %al, (%di)

  ret

# -== < CLI Tokenizer
# ===
# === < CODE
