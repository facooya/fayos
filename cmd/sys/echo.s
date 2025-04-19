# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# echo

# INDEX
# cmd_echo()

# DEPS
# cmd_echo()
#   print_newline
#   hdl_cli_opt_err

# NOTE
# [n_opt_flag]
#   0: e (escape)
#   1: n (no-newline)
#
# why set_flag
#   add $0x02, %si
#   raw_buf = cmd[0]-a[0]-b[0]

.code16
.section .text

.global cmd_echo

# ENTRY
# cmd_echo()
cmd_echo:
  # prol
  push %si
  push %ax
  push %bx
  push %cx

  # src {init}
  mov $argv, %si
  add $0x02, %si
  mov (%si), %cx
  mov $raw_buf, %si
  add %cx, %si

  # opt count * 2 {init}
  xor %cx, %cx
  
  # opt flag {init}
  xor %bx, %bx
  # bx = opt_flag [n_opt_flag]

.cmd_echo__chk_opt:
  # load
  mov (%si), %al

  # cond: hyphen ? parse_opt
  cmp $0x2D, %al
  je .cmd_echo__parse_opt

  # cond: null ? hdl_arg_err
  test %al, %al
  jz .cmd_echo__hdl_arg_err

  # skip option
  jmp .cmd_echo__parse_arg

# OPT_FLAG
.cmd_echo__parse_opt:
  # pre: (si) = hyphen
  # load
  add $0x01, %si
  mov (%si), %al

  # cond: e ? set_flag_e
  cmp $0x65, %al
  jz .cmd_echo__set_flag_e

  # cond: n ? set_flag_n
  cmp $0x6E, %al
  jz .cmd_echo__set_flag_n

  # opt err
  jmp .cmd_echo__hdl_opt_err

.cmd_echo__set_flag_e:
  # set
  bts $0x00, %bx

  # step
  add $0x02, %si
  add $0x02, %cx
  jmp .cmd_echo__chk_opt

.cmd_echo__set_flag_n:
  # set
  bts $0x01, %bx

  # step
  add $0x02, %si
  add $0x02, %cx
  jmp .cmd_echo__chk_opt

# ARG
.cmd_echo__parse_arg:
  # get {init}
  mov $argv, %si
  add $0x02, %si # skip cmd
  add %cx, %si # skip opt
  mov (%si), %cx # get offset

  # cond: cx == 0 ? hdl_arg_err
  test %cx, %cx
  jz .cmd_echo__hdl_arg_err

  # set {init}
  mov $raw_buf, %si
  add %cx, %si # set offset

# EXEC
.cmd_echo__exec:
  call print_newline

  # cond: e ? exec_opt_e
  bt $0x00, %bx
  jc .cmd_echo__exec_opt_e

  # default
  push %si
  call print_str
  add $0x02, %sp

  jmp .cmd_echo__skip_opt_e

.cmd_echo__exec_opt_e:
  push %si
  call print_esc
  add $0x02, %sp

.cmd_echo__skip_opt_e:
  # cond: n ? exec_opt_n
  bt $0x1, %bx
  jc .cmd_echo__done

  # default
  call print_newline

  jmp .cmd_echo__done

# DONE
.cmd_echo__done:
  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %si
  ret

# ERROR
.cmd_echo__hdl_opt_err:
  call print_newline

  # print opt err char
  mov $0x0E, %ah
  mov (%si), %al # opt err char
  int $0x10
  mov $0x3A, %al # colon
  int $0x10
  mov $0x20, %al # space
  int $0x10

  # print err msg
  call hdl_opt_err

  jmp .cmd_echo__done

.cmd_echo__hdl_arg_err:
  call print_newline
  call hdl_arg_err
  jmp .cmd_echo__done
