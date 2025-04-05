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
# .hdl_del()
# .hdl_bs
# .hdl_enter
# .hdl_left
# .hdl_right
# .hdl_up
# .hdl_down

# DEPS
# .hdl_ins()
#   print_str
#
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
.extern kernel_max_cur_pos_x
.extern kernel_prompt
.extern exec_cli_cmd
.extern print_str

# hdl_kbd()
hdl_kbd:
  # prol
  push %ax
  push %bx

  # al = ascii code
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

  # si = cli_buf_raw + offset
  # write
  mov %al, (%si)
  add $0x01, %si

  # max cursor
  mov (kernel_max_cur_pos_x), %al
  add $0x01, %al
  mov %al, (kernel_max_cur_pos_x)

.hdl_kbd__done:
  pop %bx
  pop %ax
  ret

.hdl_kbd__call_ins:
  push %bx # bx = ax
  push %si # origin
  call .hdl_ins
  add $0x04, %sp

  add $0x01, %si # for next
  jmp .hdl_kbd__done

# .hdl_ins()
.hdl_ins:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %ax
  push %bx # cursor
  push %cx # cursor
  push %dx # cursor

  mov 4(%bp), %di # set origin

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

.hdl_ins__tail_lp:
  # cond: null ? rsh
  mov (%di), %al
  test %al, %al
  jz .hdl_ins__rsh

  # loop
  add $0x01, %di
  jmp .hdl_ins__tail_lp

.hdl_ins__rsh:
  sub $0x01, %di # last char

.hdl_ins__rsh_lp:
  # right shift
  mov (%di), %al
  mov %al, 1(%di)

  # cond: origin ? rsh_end
  cmp %di, %si
  je .hdl_ins__rsh_end

  # loop
  sub $0x01, %di
  jmp .hdl_ins__rsh_lp

.hdl_ins__rsh_end:
  # insert
  mov 6(%bp), %ax # al = ascii code
  mov %al, (%si)

  push %si # origin
  call print_str
  add $0x02, %sp

  # set cursor
  add $0x01, %dl # x++
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10

  # max cursor
  mov (kernel_max_cur_pos_x), %al
  add $0x01, %al
  mov %al, (kernel_max_cur_pos_x)

  # epil
  pop %dx
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  pop %bp
  ret

# .hdl_bs
.hdl_bs:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try back cursor
  mov $0x02, %ah

  # reg_dl = x (current)
  # cond: max ? done
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_kbd__done

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

  # max cursor
  mov (kernel_max_cur_pos_x), %al
  sub $0x01, %al
  mov %al, (kernel_max_cur_pos_x)

  # cond: null != ? call_del
  mov (%si), %al # si = buf_raw + offset
  test %al, %al
  jnz .hdl_bs__call_del

  sub $0x01, %si # next origin
  movb $0x00, (%si)

  jmp .hdl_kbd__done

.hdl_bs__call_del:
  push %si # origin
  call .hdl_del
  add $0x02, %sp

  jmp .hdl_kbd__done

# .hdl_del()
.hdl_del:
  # prol
  push %bp
  mov %sp, %bp
  push %di
  push %ax
  push %bx
  push %cx
  push %dx

  mov 4(%bp), %di # set origin

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

.hdl_del__lsh_lp:
  # left shift
  mov (%di), %al
  mov %al, -1(%di)

  # cond: null ? lsh_end
  mov (%di), %al
  test %al, %al
  jz .hdl_del__lsh_end

  # loop
  add $0x01, %di
  jmp .hdl_del__lsh_lp

.hdl_del__lsh_end:
  # screen delete
  mov $0x20, %al # space
  mov %al, -1(%di)

  sub $0x01, %si # next origin
  
  push %si # origin
  call print_str
  add $0x02, %sp

  # set cursor
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10

  # epil
  pop %dx
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %bp
  ret

# .hdl_enter
.hdl_enter:
  call exec_cli_cmd

  push $kernel_prompt
  call print_str
  add $0x02, %sp

  # init max cursor
  mov (kernel_min_cur_pos_x), %al
  mov %al, (kernel_max_cur_pos_x)

  jmp .hdl_kbd__done

# .hdl_left
.hdl_left:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try left cursor
  mov $0x02, %ah

  # cond: min ? done
  cmp (kernel_min_cur_pos_x), %dl
  je .hdl_kbd__done

  # left cursor
  sub $0x01, %dl
  int $0x10 # x--

  sub $0x01, %si # buf_raw

  jmp .hdl_kbd__done

# .hdl_right
.hdl_right:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # try right cursor
  mov $0x02, %ah

  # cond: max ? done
  cmp (kernel_max_cur_pos_x), %dl
  je .hdl_kbd__done

  # right cursor
  add $0x01, %dl
  int $0x10 # x++

  add $0x01, %si # buf_raw
  jmp .hdl_kbd__done

# .hdl_up
.hdl_up:
  mov $0x0E, %ah
  mov $'U', %al
  int $0x10
  jmp .hdl_kbd__done

# .hdl_down
.hdl_down:
  mov $0x0E, %ah
  mov $'D', %al
  int $0x10
  jmp .hdl_kbd__done
