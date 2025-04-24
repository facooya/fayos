# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Output string

.code16
.section .text

.global puts
.global putsc

# ENTRY
# puts(addr) - put string
puts:
  # prol
  push %bp
  mov %sp, %bp
  push %si

  # init
  mov 4(%bp), %si

.puts__lp:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .puts__done

  # body
  call sys_tty_out

  # step
  add $0x01, %si
  jmp .puts__lp
  
.puts__done:
  # epil
  pop %si
  pop %bp
  ret

# ENTRY
# putsc(addr) - put string return count
# ret: cx = char count
putsc:
  # prol
  push %bp
  mov %sp, %bp
  push %si

  # init
  mov 4(%bp), %si
  xor %cx, %cx

.putsc__lp:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .putsc__done

  # body
  call sys_tty_out

  # step
  add $0x01, %si
  add $0x01, %cx
  jmp .putsc__lp
  
.putsc__done:
  # epil
  pop %si
  pop %bp
  ret
