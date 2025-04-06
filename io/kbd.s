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
# .hdl_bs_lsh()
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
# .hdl_bs_lsh()
#   kernel_min_cur_pos_x
#   kernel_max_cur_pos_x
#   print_str
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
#
# [d_nsh]
#   c: cursor, si: buf_raw ptr, dl: cursor x
#     [0]: null (buf), [ ]: space (screen)
#     {c,si,dl}: idx
#
#   <buf> facooya{si}[0]
#   <screen> facooya{c,dl}[ ]
#
#   [d_nsh.1] # back cursor
#     <screen> facooya{c,dl}[ ]
#       (c--)
#       ah=set;
#       dl--; facooy{dl}a{c}[ ]
#       int; facooy{c,dl}a[ ]
#
#   [d_nsh.2] # overwrite
#     <screen> facooy{c,dl}a[ ]
#       (c++)
#       ah=out;
#       al=[ ];
#       int; facooy{dl}[ ]{c}[ ]
#
#   [d_nsh.3] # back cursor
#     <screen> facooy{dl}[ ]{c}[ ]
#       (c=dl)
#       ah=set;
#       int; facooy{c,dl}[ ][ ]
#
#   [d_nsh.4] # ptr, buf
#     <buf> facooya{si}[0]
#       si--; facooy{si}a[0]
#       (si)=[0]; facooy{si}[0][0]
#
#   <buf> facooy{si}[0]
#   <screen> facooy{c}[ ]
#
# [d_lsh]
# 

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
  # get {cur}
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # cond: min ? done {cur}
  cmp (kernel_min_cur_pos_x), %dl # dl: cur pos x
  je .hdl_kbd__done

  # dec max {cur}
  mov (kernel_max_cur_pos_x), %al
  sub $0x01, %al
  mov %al, (kernel_max_cur_pos_x)

  # cond: null != ? call_lsh {lsh}
  mov (%si), %al # si: buf_raw ptr
  test %al, %al
  jnz .hdl_bs__call_lsh

  # default {nsh} [d_nsh]
  # back cursor {cur,nsh} [d_nsh.1]
  mov $0x02, %ah
  sub $0x01, %dl
  int $0x10

  # overwrite {cur,nsh} [d_nsh.2]
  mov $0x0E, %ah
  mov $0x20, %al # space
  int $0x10

  # back cursor {cur,nsh} [d_nsh.3]
  mov $0x02, %ah
  int $0x10

  # ptr, buf {nsh} [d_nsh.4]
  sub $0x01, %si
  movb $0x00, (%si)

  jmp .hdl_kbd__done

.hdl_bs__call_lsh:
  push %si # origin !!! facoo{c,si}ya[0]
  call .hdl_bs_lsh
  add $0x02, %sp

  jmp .hdl_kbd__done

# .hdl_bs_lsh()
.hdl_bs_lsh:
  # prol
  push %bp
  mov %sp, %bp
  push %di
  push %ax
  push %bx
  push %cx
  push %dx

  mov 4(%bp), %di # set origin !!! facoo{c,si,di}ya[0]

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

.hdl_bs_lsh__lp:
  # !!! buf: facoo{si,di}ya[0], screen: facoo{c}ya[ ]
  # left shift
  mov (%di), %al
  mov %al, -1(%di)

  # cond: null ? end
  mov (%di), %al
  test %al, %al
  jz .hdl_bs_lsh__end

  # loop
  add $0x01, %di
  jmp .hdl_bs_lsh__lp

.hdl_bs_lsh__end:
  # !!! buf: facoy{si}a[0]{di}[0]
  # !!! buf: facoy{si}a[0], screen: facoo{c}ya[ ]

  sub $0x01, %si # next origin !!! buf: faco{si}ya[0]

  # set cursor
  sub $0x01, %dl
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10 # !!! screen: faco{c}oya[ ]

  push %si # origin !!! screen: faco{c}oya[ ] => print: {si}ya{c}, screen: facoya{c}a[ ]
  call print_str
  add $0x02, %sp

  # overwrite
  mov $0x0E, %ah
  mov $0x20, %al # space
  int $0x10 # !!! screen: faco{si}oy[ ]{c}[ ]

  # set cursor
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10 # !!! screen: faco{c,si}ya{c}[ ][ ]

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
