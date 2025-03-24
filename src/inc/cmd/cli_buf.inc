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

# =============== > CODE ===============

.code16

# =============== > Key Buffer ===============
# --------------- Set Key Buffer ---------------
set_key_buf:
  mov $key_buf, %di
  ret
# --------------- Set Key Buffer ---------------

init_key_buf:
  mov $key_buf, %si
  jmp init_key_buf_loop

init_key_buf_loop:
  # Compare
  mov (%si), %al
  test %al, %al
  jz init_key_buf_exit

  # Init
  xor %al, %al
  movb %al, (%si)

  # Loop
  inc %si
  jmp init_key_buf_loop

init_key_buf_exit:
  ret

# using enter_key (kbd.inc)
init_cmd_buf: # Temporary
  mov $cmd_buf, %si
  jmp init_key_buf_loop

init_arg_buf: # Temporary
  mov $arg_buf, %si
  jmp init_key_buf_loop

init_opt_buf: # Temporary
  mov $opt_buf, %si
  jmp init_key_buf_loop

init_tmp_buf: # Temporary
  mov $tmp_buf, %si
  jmp init_key_buf_loop

init_redir_buf: # Temporary
  mov $redir_buf, %si
  jmp init_key_buf_loop

# =============== < Key Buffer ===============

# =============== < CODE ===============
# =============== > DATA ===============

key_buf: .zero 0x40
cmd_buf: .zero 0x20
arg_buf: .zero 0x20
opt_buf: .zero 0x10
tmp_buf: .zero 0x20
redir_buf: .zero 0x20

cli_buf_raw: .zero 0x40
cli_buf_cmd: .zero 0x20
cli_buf_arg: .zero 0x20
cli_buf_opt: .zero 0x10
cli_buf_tmp: .zero 0x20
cli_buf_redir: .zero 0x20

# =============== < DATA ===============
