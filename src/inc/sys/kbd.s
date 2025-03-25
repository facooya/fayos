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
.section .text

# FUNC
.global kbd_disp
.global newline
.global set_cursor_min_x

# DEPS
.extern kernel_prompt # kernel.s DATA
.extern kernel__cur_min_x # kernel.s DATA
.extern cmd_exec # cmd_exec.s FUNC
.extern cli_buf_init_all # cli_buf.s FUNC
.extern print_str # print.s FUNC

# FUNC
kbd_disp:
  # Cond: BS ? _kbd_bs
  cmp $0x08, %al # BS
  je _kbd_bs

  # Cond: CR ? _kbd_enter
  cmp $0x0D, %al # CR
  je _kbd_enter

  # Else
  mov $0x0E, %ah # out set
  int $0x10 # out

  # Save
  mov %al, (%si) # SI: cli_buf_raw
  add $0x01, %si # prepare SI for next byte

_kbd_disp__done:
  ret

# FUNC
_kbd_bs:
  # Get cursor
  mov $0x03, %ah
  mov $0x00, %bh # page number
  int $0x10 # return: DH=y, DL=x

  # Set cursor
  mov $0x02, %ah

  # Cond: (cur_min_x == x) ? done
  mov $kernel__cur_min_x, %di
  movb (%di), %al
  cmp %al, %dl # DL = x
  #cmp (kernel__cur_min_x), %dl
  je _kbd_bs__done

  # Back cursor
  sub $0x01, %dl
  int $0x10 # Set cursor end

  # Out space
  mov $0x0E, %ah
  mov $0x20, %al # 0x20: space
  int $0x10

  # Set cursor back
  mov $0x02, %ah
  int $0x10

  # SI: cli_buf_raw
  sub $0x01, %si
  movb $0x00, (%si)

_kbd_bs__done:
  ret

# FUNC
_kbd_enter:
  # Command
  call cmd_exec # cmd_exec.s

  # Initialize buffers
  call cli_buf_init_all # cli_buf.s

  # Out
  push $kernel_prompt # kernel.s
  call print_str # print.s
  add $0x02, %sp

  # Set buffer raw
  call cli_buf_raw_set # cli_buf.s

_kdb_enter__done:
  ret

# =============== > Utils =============== # !!! Temporary
# --------------- New Line ---------------
newline:
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10
  ret

# === < CODE
