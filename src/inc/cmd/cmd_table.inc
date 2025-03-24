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

# === > PRIVIEW

# DATA
# cmd_table

# === < PRIVIEW
# ===
# === > DATA

cmd_table:
  .word cmd_clear
  .asciz "clear"
  .word cmd_echo
  .asciz "echo"
  .word cmd_touch
  .asciz "touch"
  .word cmd_rm
  .asciz "rm"
  .word cmd_ls
  .asciz "ls"
  .word cmd_cat
  .asciz "cat"
  .word cmd_help
  .asciz "help"
  .word 0x00
  .asciz ""

# === < DATA
