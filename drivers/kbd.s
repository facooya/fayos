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

# INDEX
# hdl_kbd()
#
# .hdl_ins()
# .hdl_bs()
# .hdl_enter()
# .hdl_left()
# .hdl_right()
# .hdl_up()
# .hdl_down()

# DEPS
# .hdl_bs()
#   kernel_min_cur_pos_x
#
# .hdl_enter()
#   kernel_prompt
#   exec_cli_cmd
#   print_str

# NOTE
# [n_arrow]
#   normal only
#   AL: 0x00 - no ascii code
#   AH:
#     0x4B - left
#     0x4D - right
#     0x48 - up
#     0x50 - down

.code16
.section .text

.global hdl_kbd

.extern kernel_min_cur_pos_x
.extern kernel_prompt
.extern exec_cli_cmd
.extern print_str

# hdl_kbd()
hdl_kbd:
  # reg_al = ascii code
  # cond
  cmp $0x08, %al # backspace
  je .hdl_bs

  # cond
  cmp $0x0D, %al # carriage return (enter)
  je .hdl_enter

  # cond arrow [n_arrow]
  cmp $0x4B00, %ax # left
  je .hdl_left
  cmp $0x4D00, %ax # right
  je .hdl_right
  cmp $0x4800, %ax # up
  je .hdl_up
  cmp $0x5000, %ax # down
  je .hdl_down

  # cond: null != ? .hdl_kbd__call_ins
  mov %ax, %bx # push
  mov (%si), %al
  test %al, %al
  jnz .hdl_kbd__call_ins
  mov %bx, %ax # pop

  # default
  mov $0x0E, %ah
  int $0x10

  # reg_si = cli_buf_raw + offset
  # write
  mov %al, (%si)
  add $0x01, %si
  ret

.hdl_kbd__call_ins:
  push %bx
  push %si # origin
  call .hdl_ins
  add $0x04, %sp
  ret

# .hdl_ins()
.hdl_ins:
  # prol
  push %bp
  mov %sp, %bp

  mov 4(%bp), %di # set origin

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

.hdl_kbd__tail_lp: # !!! change name .hdl_ins__*
  # cond: null ? rewrite
  mov (%di), %al
  test %al, %al
  jz .hdl_kbd__rewrite

  # loop
  add $0x01, %di
  jmp .hdl_kbd__tail_lp

.hdl_kbd__rewrite:
  sub $0x01, %di # last char

.hdl_kbd__rewrite_lp:
  # right shift
  mov (%di), %al
  mov %al, 1(%di)

  # cond: origin ? rewrite_end
  cmp %di, %si
  je .hdl_kbd__rewrite_end

  # loop
  sub $0x01, %di
  jmp .hdl_kbd__rewrite_lp

.hdl_kbd__rewrite_end:
  mov 6(%bp), %ax
  mov %al, (%si)

.hdl_kbd__out:
  mov $0x0E, %ah

.hdl_kbd__out_lp:
  # cond: null ? out_end
  mov (%si), %al
  test %al, %al
  jz .hdl_kbd__out_end

  # out
  int $0x10

  # loop
  add $0x01, %si
  jmp .hdl_kbd__out_lp

.hdl_kbd__out_end:
  # get origin
  mov 4(%bp), %si
  add $0x01, %si

  # set cursor
  add $0x01, %dl
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10

  # epil
  pop %bp
  ret

# .hdl_bs()
.hdl_bs:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try back cursor
  mov $0x02, %ah

  # reg_dl = x (current)
  # cond
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_bs__done

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

.hdl_bs__done:
  ret

# .hdl_enter()
.hdl_enter:
  call exec_cli_cmd

  push $kernel_prompt
  call print_str
  add $0x02, %sp
  ret

# .hdl_left()
.hdl_left:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try left cursor
  mov $0x02, %ah

  # reg_dl = x (current)
  # cond
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_left__done

  # left cursor
  sub $0x01, %dl
  int $0x10 # x--

  sub $0x01, %si # buf_raw

.hdl_left__done:
  ret

# .hdl_right()
.hdl_right:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try right cursor
  mov $0x02, %ah

  # right cursor !!! max_cur_pos_x
  add $0x01, %dl
  int $0x10 # x++

  add $0x01, %si # buf_raw
  ret

# .hdl_up()
.hdl_up:
  mov $0x0E, %ah
  mov $'U', %al
  int $0x10
  ret

# .hdl_down()
.hdl_down:
  mov $0x0E, %ah
  mov $'D', %al
  int $0x10
  ret
