# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Arguments

.code16
.section .text

.global trim_raw
.global split_raw
.global build_args
.global norm_args

.global clear_args
.global clear_buf

.global argc
.global argv
.global raw_buf

.global dout # !!! DEBUG
# !!! dout() TMP
dout:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si
  mov $0x0E, %ah

.dout_lp:
  mov (%si), %al # load

  # cond: null ? chk
  test %al, %al
  jz .dout_chk

  int $0x10 # out

  # loop
  add $0x01, %si
  jmp .dout_lp

.dout_chk:
  mov $'0', %al
  int $0x10

  add $0x01, %si
  mov (%si), %al # load

  # cond: null ? done
  test %al, %al
  jz .dout_done

  # loop
  jmp .dout_lp

.dout_done:
  pop %ax
  pop %si
  pop %bp
  ret

# trim_raw()
trim_raw:
  # prol
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  # init
  mov $raw_buf, %si
  xor %cx, %cx

.trim_raw__left_lp: # !!! {si}[ ][ ]echo[ ]facooya[ ][ ][0]
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .trim_raw__done

  # cond: space != ? left_end
  cmp $0x20, %al
  jne .trim_raw__left_end

  # loop
  add $0x01, %si
  add $0x01, %cx
  jmp .trim_raw__left_lp

.trim_raw__left_end:
  # !!! si,cx=2
  # !!! [ ][ ]{si}echo[ ]facooya[ ][ ][0]
  mov %si, %di # di = left valid idx
  # !!! di=2

  # !!! for push $raw_buf => push %si
  sub %cx, %si # si = left idx
  xor %cx, %cx

  # !!! TODO
  # push $raw_buf
  # call strlen
  # add $0x02, %sp
  # mov $raw_buf, %si
  # add %cx, %si

.trim_raw__strlen_lp: # !!! TMP
  # !!! [ ][ ]echo[ ]facooya[ ][ ]{si,cx}[0] si,cx=16
  # cond: null ? right
  mov (%si), %al
  test %al, %al
  jz .trim_raw__right

  # loop
  add $0x01, %si
  add $0x01, %cx
  jmp .trim_raw__strlen_lp

.trim_raw__right:
  sub $0x01, %si
  mov %si, %bx # bx = right idx
  # !!! si,bx=15, cx=16
  # !!! [ ][ ]echo[ ]facooya[ ]{si,bx}[ ][0]

.trim_raw__right_lp:
  # !!! si,bx=15 - 2 = 13
  # !!! [ ][ ]echo[ ]facooy{si,bx}a[ ][ ][0]
  # load
  mov (%si), %al

  # cond: space != ? compact
  cmp $0x20, %al
  jne .trim_raw__compact

  # loop
  sub $0x01, %si
  sub $0x01, %bx
  jmp .trim_raw__right_lp

.trim_raw__compact:
  # di = left valid idx !!! 2
  # bx = right valid idx !!! 13
  # cx = str len !!! 16

  # init
  mov $raw_buf, %si # dst

.trim_raw__compact_lp:
  # !!! {si}[ ][ ]{di}echo[ ]facooy{bx}a[ ][ ]{cx}[0]
  # copy
  mov (%di), %al
  mov %al, (%si)
  
  # cond: di == bx ? zero
  cmp %bx, %di
  je .trim_raw__zero

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .trim_raw__compact_lp

.trim_raw__zero:
  # !!! di,bx = right valid idx
  # !!! cx = str len

  # init
  add $0x01, %si

.trim_raw__zero_lp:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .trim_raw__done

  # store zero
  xor %al, %al
  mov %al, (%si)

  # step
  add $0x01, %si
  jmp .trim_raw__zero_lp

.trim_raw__done:
  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  ret

# ENTRY
# split_raw()
#   si = raw_buf (src)
#   di = tmp_buf (dst)
split_raw:
  # prol
  push %si
  push %di
  push %ax

  # clear tmp_buf
  push $tmp_buf
  call clear_buf
  add $0x02, %sp

  # init
  mov $raw_buf, %si
  mov $tmp_buf, %di

.split_raw__write_lp:
  # pre: si = next_char
  # pre: di = write
  # load
  mov (%si), %al

  # cond: null ? copy
  test %al, %al
  jz .split_raw__copy

  # cond: space ? skip_space
  cmp $0x20, %al
  je .split_raw__skip_space

  # store
  mov %al, (%di)

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .split_raw__write_lp

# SKIP_SPACE
.split_raw__skip_space:
  # store null
  xor %al, %al
  mov %al, (%di)
  add $0x01, %di

  # (si) = space
  # init
  add $0x01, %si

.split_raw__skip_space_lp:
  # load
  mov (%si), %al

  # cond: space != ? chk_opt
  cmp $0x20, %al
  jne .split_raw__chk_opt

  # step
  add $0x01, %si
  jmp .split_raw__skip_space_lp

.split_raw__chk_opt:
  # (si) != space
  # cond: hyphen ? norm_opt
  cmp $0x2D, %al
  je .split_raw__norm_opt
  
  # next
  jmp .split_raw__write_lp

# NORM_OPT
.split_raw__norm_opt:
  # (si),al = hyphen
  # init
  mov %al, %ah
  add $0x01, %si
  # (si) = opt_char

.split_raw__norm_opt_lp:
  # load opt_char
  mov (%si), %al

  # cond: space ? norm_opt_end
  cmp $0x20, %al
  je .split_raw__norm_opt_end

  # cond: null ? norm_opt_end
  test %al, %al
  jz .split_raw__norm_opt_end

  # store hyphen
  mov %ah, (%di)
  add $0x01, %di

  # store opt_char
  mov %al, (%di)
  add $0x01, %di

  # store null
  xor %al, %al
  mov %al, (%di)
  add $0x01, %di

  # step
  add $0x01, %si
  jmp .split_raw__norm_opt_lp

.split_raw__norm_opt_end:
  # (si) = space
  add $0x01, %si

  # next
  jmp .split_raw__write_lp

# COPY
.split_raw__copy:
  # init
  mov $tmp_buf, %si
  mov $raw_buf, %di

.split_raw__copy_lp:
  # load
  mov (%si), %al

  # cond: null ? chk_copy
  test %al, %al
  jz .split_raw__chk_copy

  # store
  mov %al, (%di)

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .split_raw__copy_lp

.split_raw__chk_copy:
  # store null
  mov %al, (%di)
  add $0x01, %di

  # load
  add $0x01, %si
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .split_raw__done

  # continue
  jmp .split_raw__copy_lp

.split_raw__done:
  # epil
  pop %ax
  pop %di
  pop %si
  ret

# build_args()
build_args:
  # prol
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  # init
  call clear_args
  mov $raw_buf, %si

  # init argv
  mov $argv, %di
  xor %bx, %bx # off
  mov %bx, (%di)
  add $0x02, %di

  # init argc
  xor %cx, %cx # argc

.build_args__argv_lp:
  mov (%si), %al # load (raw_buf)

  # cond: null ? argc
  test %al, %al
  jz .build_args__argc

  # loop
  add $0x01, %si # raw_buf
  add $0x01, %bx # offset
  jmp .build_args__argv_lp

.build_args__argc:
  add $0x01, %cx # argc

  # write argv
  add $0x01, %bx # skip null
  mov %bx, (%di) # store (argv)
  add $0x02, %di # argv

  add $0x01, %si
  mov (%si), %al # load (raw)

  # cond: null ? done
  test %al, %al
  jz .build_args__done

  # loop
  jmp .build_args__argv_lp

.build_args__done:
  # write argc
  mov $argc, %si
  mov %cx, (%si)

  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  ret

# clear_args()
clear_args:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # init
  mov $argv, %si
  mov $argc, %di
  mov (%di), %cx

.clear_args__zero_lp:
  # cond: cx == 0 ? done
  test %cx, %cx
  jz .clear_args__done

  # zero
  mov (%si), %ax # load (argv)
  xor %ax, %ax
  mov %ax, (%si) # store (argv)

  # loop
  add $0x02, %si
  sub $0x01, %cx
  jmp .clear_args__zero_lp

.clear_args__done:
  mov %cx, (%di) # store (argc)

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret

# clear_buf()
clear_buf:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # init
  mov 4(%bp), %si

.clear_buf__zero_lp:
  # load
  mov (%si), %al

  # cond: null ? chk_zero
  test %al, %al
  jz .clear_buf__chk_zero

  # store zero
  xor %al, %al
  mov %al, (%si)

  # loop
  add $0x01, %si
  jmp .clear_buf__zero_lp

.clear_buf__chk_zero:
  # next load
  add $0x01, %si
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .clear_buf__done

  # loop
  jmp .clear_buf__zero_lp

.clear_buf__done:
  # epil
  pop %ax
  pop %si
  pop %bp
  ret

.section .data

# args
argc: .word 0x00
argv: .zero 0x100

# bufs
raw_buf: .zero 0x400
tmp_buf: .zero 0x400
