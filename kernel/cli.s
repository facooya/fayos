# FAYOS - FAcooYa Operating System
#
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

.global cmd_exec # exec_cli() !!!
.global cli_buf_raw_set # set_cli_buf_raw() !!!
.global cli_buf_init_all # init_cli_buf_init() !!!\
.global cmd_table
.global cli_buf_raw, cli_buf_cmd, cli_buf_arg
.global cli_buf_opt, cli_buf_tmp, cli_buf_redir

# exec_cli()
cmd_exec:
  call cli_tok

  mov $cmd_table, %si

_cmd_exec__chk_addr:
  # Null ? not_found
  mov (%si), %bx
  test %bx, %bx
  jz err_cmd # ref: err.inc

_cmd_exec__cmp_cmd:
  add $0x02, %si # cmd_table byte
  mov $cli_buf_cmd, %di

_cmd_exec__cmp_cmd_lp:
  # Char != : next_lp
  mov (%si), %al
  cmp (%di), %al
  jne _cmd_exec__next_lp

  # Found
  test %al, %al
  jz _cmd_exec__call

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cmd_exec__cmp_cmd_lp

_cmd_exec__next_lp:
  # Char
  mov (%si), %al
  test %al, %al
  jz _cmd_exec__next_end

  # Loop
  add $0x01, %si
  jmp _cmd_exec__next_lp

_cmd_exec__next_end:
  add $0x01, %si
  jmp _cmd_exec__chk_addr

_cmd_exec__call:
  call *%bx

_cmd_exec__done:
  ret

# set_cli_buf_raw()
cli_buf_raw_set:
  mov $cli_buf_raw, %si
  ret

# init_cli_buf_all()
cli_buf_init_all:
  push $cli_buf_raw
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_cmd
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_arg
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_opt
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_tmp
  call cli_buf_init
  add $0x02, %sp

  push $cli_buf_redir
  call cli_buf_init
  add $0x02, %sp

  ret

# init_cli_buf(cli_buf)
cli_buf_init:
_cli_buf_init__prol:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si

_cli_buf_init__lp:
  # Cond: null ? end
  mov (%si), %al
  test %al, %al
  jz _cli_buf_init__end

  # Init
  xor %al, %al
  movb %al, (%si)

  # Loop: SI++
  add $0x01, %si
  jmp _cli_buf_init__lp

_cli_buf_init__end:
_cli_buf_init__epil:
  pop %ax
  pop %si
  pop %bp

_cli_buf_init__done:
  ret

# tok_cli_buf()
cli_tok:
_cli_tok__prol:
  call cli_buf_raw_set

_cli_tok__buf_cmd_set:
  mov $cli_buf_cmd, %di

_cli_tok__buf_cmd_lp:
  # Cond: null ? buf_cmd_exit
  mov (%si), %al # SI: cli_buf_raw
  test %al, %al
  jz _cli_tok__buf_cmd_exit

  # Cond: space ? buf_cmd_end
  cmp $0x20, %al # 0x20: SPACE
  jz _cli_tok__buf_cmd_end

  # Save
  mov %al, (%di) # DI: cli_buf_cmd

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cli_tok__buf_cmd_lp

_cli_tok__buf_cmd_end:
  # SI: Space, SI+1: Hyphen-Minus || Argument
  add $0x01, %si

  # Cond: !Hyphen-Minus ? buf_opt_end
  mov (%si), %al
  cmp $0x2D, %al # 0x2D: Hyphen-Minus
  jne _cli_tok__buf_opt_end

  # Else: buf_opt_set

_cli_tok__buf_opt_set:
  # SI: Hyphen-Minus, SI+1: Option
  add $0x01, %si
  mov $cli_buf_opt, %di

_cli_tok__buf_opt_lp:
  # Cond: null ? buf_opt_exit
  mov (%si), %al
  test %al, %al
  jz _cli_tok__buf_opt_exit

  # Cond: space ? buf_opt_chk
  mov (%si), %al
  cmp $0x20, %al # 0x20: Space
  je _cli_tok__buf_opt_chk

  # Save
  mov %al, (%di) # DI: cli_buf_opt

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cli_tok__buf_opt_lp

_cli_tok__buf_opt_chk:
  # SI: space, SI+1: hyphen-minus || argument
  add $0x01, %si

  # Cond: !hyphen-minus ? buf_opt_end
  mov (%si), %al
  cmp $0x2D, %al # 0x2D: hyphen-minus
  jne _cli_tok__buf_opt_end

  # Else: continue
  # SI: hyphen-minus, SI+1: option
  add $0x01, %si
  jmp _cli_tok__buf_opt_lp

_cli_tok__buf_opt_end:
  # SI: argument

_cli_tok__buf_arg_set:
  mov $cli_buf_arg, %di

_cli_tok__buf_arg_lp:
  # Cond: null ? buf_arg_end
  mov (%si), %al
  test %al, %al
  jz _cli_tok__buf_arg_end

  # Save
  mov %al, (%di) # DI: cli_buf_arg

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cli_tok__buf_arg_lp

_cli_tok__buf_arg_end:
  # SI: null

_cli_tok__epli:
_cli_tok__done:
  ret

_cli_tok__buf_cmd_exit: # !!! Temporary
  xor %al, %al
  mov %al, (%di)

  ret

_cli_tok__buf_opt_exit: # !!! Temporary
  xor %al, %al
  mov %al, (%di)

  ret

err_cmd: # !!! err_cmd => cli.s
  call newline # kbd.inc !!! Delete

  # Print
  push $.cmd_err_msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc !!! Delete
  ret

.section .data

# cmd_table
cmd_table:
  .word cmd_clear
  .asciz "clear"
  .word cmd_echo
  .asciz "echo"
  .word cmd_touch
  .asciz "touch"
  .word cmd_rm
  .asciz "rm"
  .word cmd_ls
  .asciz "ls"
  .word cmd_cat
  .asciz "cat"
  .word cmd_help
  .asciz "help"
  .word 0x00
  .asciz ""

# cli buffers
cli_buf_raw: .zero 0x40
cli_buf_cmd: .zero 0x20
cli_buf_arg: .zero 0x20
cli_buf_opt: .zero 0x10
cli_buf_tmp: .zero 0x20
cli_buf_redir: .zero 0x20

# err
.cmd_err_msg: .asciz "Command not found. Try \"help\" for a list of commands."
