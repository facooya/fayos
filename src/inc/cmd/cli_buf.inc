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
# cli_buf_raw_set()
# cli_buf_init_all()
# cli_buf_init(&cli_buf)

# DATA
# cli_buf_raw
# cli_buf_cmd
# cli_buf_arg
# cli_buf_opt
# cli_buf_redir

# === < PREVIEW
# ===
# === > CODE

.code16

# -== > raw set

cli_buf_raw_set:
  mov $cli_buf_raw, %si
  ret

# -== < raw set
# ===
# -== > Init all

cli_buf_init_all:
  push $cli_buf_raw
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_cmd
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_arg
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_opt
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_tmp
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_redir
  call cli_buf_init
  add $0x02, %sp

  ret

# -== < Init all
# ===
# -== > Init

# cli_buf_init(&cli_buf)
cli_buf_init:
_cli_buf_init__prol:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si

_cli_buf_init__lp:
  # Cond: null ? end
  mov (%si), %al
  test %al, %al
  jz _cli_buf_init__end

  # Init
  xor %al, %al
  movb %al, (%si)

  # Loop: SI++
  add $0x01, %si
  jmp _cli_buf_init__lp

_cli_buf_init__end:
_cli_buf_init__epil:
  pop %ax
  pop %si
  pop %bp

_cli_buf_init__done:
  ret

# -== < Init
# ===
# === < CODE
# ===
# === > DATA

cli_buf_raw: .zero 0x40

cli_buf_cmd: .zero 0x20
cli_buf_arg: .zero 0x20
cli_buf_opt: .zero 0x10

cli_buf_tmp: .zero 0x20

cli_buf_redir: .zero 0x20

# === < DATA
