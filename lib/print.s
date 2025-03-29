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

.code16
.section .text

.global print_str
.global print_esc
.global print_newline

# print_str(str_addr)
print_str:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si
  mov $0x0E, %ah

.print_str__out_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .print_str__done

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .print_str__out_lp

.print_str__done:
  pop %ax
  pop %si
  pop %bp
  ret

# print_esc(str_addr)
print_esc:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si
  mov $0x0E, %ah

.print_esc__out_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .print_esc__done

  # cond: backslash ? hdl_esc
  cmp $0x5C, %al # backslash
  jz .print_esc__hdl_esc

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .print_esc__out_lp

.print_esc__hdl_esc:
  add $0x01, %si
  mov (%si), %al

  # cond: n ? esc_n
  cmp $0x6E, %al # n
  jz .print_esc__hdl_esc_n

  # out
  mov $0x5C, %al # backslash
  int $0x10

  # loop
  jmp .print_esc__out_lp

.print_esc__hdl_esc_n:
  call print_newline

  # end
  jmp .print_esc__hdl_esc_end

# .print_esc__hdl_esc_*: # more escape char here

.print_esc__hdl_esc_end:
  # loop
  add $0x01, %si
  jmp .print_esc__out_lp

.print_esc__done:
  pop %ax
  pop %si
  pop %bp
  ret

# print_newline()
print_newline:
  push %ax
  mov $0x0E, %ah
  mov $0x0D, %al # CR
  int $0x10
  mov $0x0A, %al # LF
  int $0x10
  pop %ax
  ret
