# SPDX-License-Identifier: GPL-3.0-or-later
#
# Keyboard handler for kernel (docs/io/kbd.txt)
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

.code16
.section .text

.global hdl_kbd

.extern cur
.extern kernel_prompt
.extern exec_cli_cmd
.extern print_str

# hdl_kbd() - main keyborad handler
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
  mov (cur+1), %al
  add $0x01, %al
  mov %al, (cur+1)

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

# .hdl_ins() - insert text
.hdl_ins:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %di
  push %ax
  push %bx
  push %cx
  push %dx

  mov 4(%bp), %di # set origin

  # get {cur}
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

  # set {cur}
  add $0x01, %dl
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10

  # set max {cur}
  mov (cur+1), %al
  add $0x01, %al
  mov %al, (cur+1)

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
  cmp (cur), %dl # dl: cur pos x
  je .hdl_kbd__done

  # dec max {cur}
  mov (cur+1), %al # max
  sub $0x01, %al
  mov %al, (cur+1)

  # cond: null != ? call_lsh {lsh}
  mov (%si), %al # si: buf_raw ptr
  test %al, %al
  jnz .hdl_bs__call_lsh

  # default {nsh} [d_nsh]
  # back {cur,nsh} [d_nsh.1]
  mov $0x02, %ah
  sub $0x01, %dl
  int $0x10

  # overwrite {cur,nsh} [d_nsh.2]
  mov $0x0E, %ah
  mov $0x20, %al # space
  int $0x10

  # back {cur,nsh} [d_nsh.3]
  mov $0x02, %ah
  int $0x10

  # ptr, buf {nsh} [d_nsh.4]
  sub $0x01, %si
  movb $0x00, (%si)

  jmp .hdl_kbd__done

.hdl_bs__call_lsh:
  push %si # buf_raw ptr
  call .hdl_bs_lsh
  add $0x02, %sp

  jmp .hdl_kbd__done

# .hdl_bs_lsh() - delete text
.hdl_bs_lsh:
  # prol
  push %bp
  mov %sp, %bp
  push %di
  push %ax
  push %bx
  push %cx
  push %dx

  mov 4(%bp), %di # buf_raw ptr

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

.hdl_bs_lsh__lp: # [d_lsh.1]
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
  # back {cur} [d_lsh.2]
  sub $0x01, %dl
  mov $0x02, %ah
  mov $0x00, %bh
  int $0x10

  # write [d_lsh.3]
  sub $0x01, %si
  push %si
  call print_str
  add $0x02, %sp

  # overwrite [d_lsh.4]
  mov $0x0E, %ah
  mov $0x20, %al # space
  int $0x10

  # back {cur} [d_lsh.5]
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
  mov (cur), %al
  mov %al, (cur+1)

  jmp .hdl_kbd__done

# .hdl_left
.hdl_left:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # cond: min ? done
  cmp (cur), %dl
  je .hdl_kbd__done

  # left cursor
  sub $0x01, %dl
  mov $0x02, %ah
  int $0x10 # x--

  sub $0x01, %si # buf_raw

  jmp .hdl_kbd__done

# .hdl_right
.hdl_right:
  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # cond: max ? done
  cmp (cur+1), %dl
  je .hdl_kbd__done

  # right cursor
  add $0x01, %dl
  mov $0x02, %ah
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
