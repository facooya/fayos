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

# =============== > PREVIEW ===============

# FUNC
# key_manager()

# DEPS
# /cmd/proc.inc (FUNC: cmd_proc())

# =============== < PREVIEW ===============
# =============== > CODE ===============

.code16

# =============== > Key Manager ===============

key_manager:
  cmp $0x08, %al # BS
  jz bs_key
  cmp $0x0D, %al # CR
  jz enter_key

  # Else
  mov $0x0E, %ah
  int $0x10

  mov %al, (%di) # DI = key_buf
  inc %di

  jmp key_manager_exit

key_manager_exit:
  ret

# =============== < Key Manager ===============
# =============== > Key Handlers ===============

# --------------- BackSpace ---------------
bs_key:
  mov $0x03, %ah # Get Cursor Pos
  mov $0x00, %bh # Video Page Number
  int $0x10 # DH=Y, DL=X

  mov $0x02, %ah # Set Cursor Pos, DH=Y, DL=X
  cmp (cursor_min_x), %dl
  jz key_manager_exit
  dec %dl
  int $0x10

  mov $0x0E, %ah
  mov $0x20, %al # SP
  int $0x10

  mov $0x02, %ah # Set Cursor Pos, DH=Y, DL=X
  int $0x10

  # key_buf
  movb $0x00, -1(%di)
  dec %di

  jmp key_manager_exit

# --------------- Enter ---------------
enter_key:
  # Command
  #call find_cmd # newline() Self
  call parse_key_buf # => cli_tok
  call cmd_exec # (cmd_exec.inc)

  # Init buffers
  call init_key_buf
  call init_cmd_buf
  call init_arg_buf
  call init_opt_buf
  call init_redir_buf

  push $kernel_prompt
  call print_str
  add $0x02, %sp
  
  mov $key_buf, %di
  jmp key_manager_exit

# =============== < Key Handlers ===============
# =============== > Utils ===============
# --------------- New Line ---------------
newline:
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10
  ret

# --------------- Set Cursor Minimum X ---------------
set_cursor_min_x:
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10
  mov %dl, (cursor_min_x)
  ret

# =============== < Utils ===============

# =============== < CODE ===============
# =============== > DATA ===============

cursor_min_x: .byte 0x00

# =============== < DATA ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
