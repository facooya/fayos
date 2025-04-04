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
# .hdl_kbd__bs()
# .hdl_kbd__enter()
# .hdl_kbd__left()
# .hdl_kbd__right()
# .hdl_kbd__up()
# .hdl_kbd__down()

# DEPS
# .hdl_kbd__bs()
#   kernel_min_cur_pos_x
#
# .hdl_kbd__enter()
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
  je .hdl_kbd__bs

  # cond
  cmp $0x0D, %al # carriage return (enter)
  je .hdl_kbd__enter

  # cond arrow [n_arrow]
  cmp $0x4B00, %ax # left
  je .hdl_kbd__left
  cmp $0x4D00, %ax # right
  je .hdl_kbd__right
  cmp $0x4800, %ax # up
  je .hdl_kbd__up
  cmp $0x5000, %ax # down
  je .hdl_kbd__down

  push %ax
  # cond: null != ? .hdl_kbd__shf_buf
  mov (%si), %al
  test %al, %al
  jnz .hdl_kbd__shf_buf
  pop %ax

  # default
  mov $0x0E, %ah
  int $0x10

  # reg_si = cli_buf_raw + offset
  # write
  mov %al, (%si)
  add $0x01, %si
  ret

.hdl_kbd__shf_buf:
  # mov (%si), %al
  # mov %al, 1(%si)

  # pop %ax

  # mov $0x0E, %ah
  # int $0x10
  # mov 1(%si), %al
  # int $0x10

  # add $0x01, %si
  mov %si, %di

.hdl_kbd__shf_buf_lp:
  # cond: null ? end
  mov (%si), %al
  test %al, %al
  jz .hdl_kbd__shf_buf_end

  # loop
  add $0x01, %si
  add $0x01, %bx
  jmp .hdl_kbd__shf_buf_lp

.hdl_kbd__shf_buf_end:
# .hdl_kbd__out:
#   sub $0x01, %bx
#   mov %di, %si

# .hdl_kbd__out_lp:
#   mov (%bx,%si), %al
#   mov %al, 1(%bx,%si)
#   mov $0x0E, %ah
#   int $0x10

#   test %bx, %bx
#   jz .hdl_kbd__out_end

#   #add $0x01, %si
#   sub $0x01, %bx
#   jmp .hdl_kbd__out_lp

# .hdl_kbd__out_end:
#   add $0x01, %si
#   xor %bx, %bx
#   pop %ax
#   ret

.hdl_kbd__write:
  mov %di, %si

.hdl_kbd__write_lp:
  # right shift
  mov (%bx,%si), %al
  mov %al, 1(%bx,%si)

  # cond: 0 ? write_end
  test %bx, %bx
  jz .hdl_kbd__write_end

  # loop
  sub $0x01, %bx
  jmp .hdl_kbd__write_lp

.hdl_kbd__write_end:
  pop %ax
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
  ret

# .hdl_kbd__bs()
.hdl_kbd__bs:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try back cursor
  mov $0x02, %ah

  # reg_dl = x (current)
  # cond
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_kbd__bs_done

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

.hdl_kbd__bs_done:
  ret

# .hdl_kbd__enter()
.hdl_kbd__enter:
  call exec_cli_cmd

  push $kernel_prompt
  call print_str
  add $0x02, %sp
  ret

# .hdl_kbd__left()
.hdl_kbd__left:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try left cursor
  mov $0x02, %ah

  # reg_dl = x (current)
  # cond
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_kbd__bs_done

  # left cursor
  sub $0x01, %dl
  int $0x10 # x--

  sub $0x01, %si # buf_raw
  ret

# .hdl_kbd__right()
.hdl_kbd__right:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try right cursor
  mov $0x02, %ah

  # right cursor !!! max_cur_pos_x
  add $0x01, %dl
  int $0x10 # x++
  ret

# .hdl_kbd__up()
.hdl_kbd__up:
  mov $0x0E, %ah
  mov $'U', %al
  int $0x10
  ret

# .hdl_kbd__down()
.hdl_kbd__down:
  mov $0x0E, %ah
  mov $'D', %al
  int $0x10
  ret
