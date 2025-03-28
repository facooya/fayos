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

# DEPS
# .hdl_bs()
# - kernel_min_cur_pos_x
#
# .hdl_enter()
# - kernel_prompt
# - exec_cli_cmd
# - print_str

.code16
.section .text

.global hdl_kbd
.global newline # !!! Delete

.extern kernel_min_cur_pos_x
.extern kernel_prompt
.extern exec_cli_cmd
.extern print_str

# hdl_kbd()
hdl_kbd:
  # reg_al = ascii code
  # cond
  cmp $0x08, %al # backspace
  je .hdl_kbd_bs

  # cond
  cmp $0x0D, %al # carriage return (enter)
  je .hdl_kbd_enter

  # out
  mov $0x0E, %ah
  int $0x10

  # reg_si = cli_buf_raw + offset
  # write
  mov %al, (%si)
  add $0x01, %si

  ret

# .hdl_kbd_bs()
.hdl_kbd_bs:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try back cursor
  mov $0x02, %ah

  # reg_dl = x (current)
  # cond
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_kbd_bs_done

  # back cursor
  sub $0x01, %dl
  int $0x10 # x--

  # overwrite
  mov $0x0E, %ah
  mov $0x20, %al # space
  int $0x10 # x++

  # back cursor (again)
  mov $0x02, %ah
  int $0x10 # x--

  # reg_si = cli_buf_raw + offset
  sub $0x01, %si
  movb $0x00, (%si)

.hdl_kbd_bs_done:
  ret

# .hdl_kbd_enter()
.hdl_kbd_enter:
  call exec_cli_cmd

  push $kernel_prompt
  call print_str
  add $0x02, %sp

  ret


# !!! Delete
# =============== > Utils =============== # !!! Temporary
# --------------- New Line ---------------
newline:
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10
  ret
