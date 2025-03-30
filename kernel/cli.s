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
# exec_cli_cmd()
# hdl_cli_opt_err
# cli_cmd_map
# cli_buf_*
# cli_cwd_lba
#
# .tok_cli_buf()
# .init_cli_buf_all()
# .init_cli_buf(cli_buf)

# DEPS
# exec_cli_cmd()
#   print_newline
#
# cli_cmd_map
#   cmd_*

.code16
.section .text

.global exec_cli_cmd
.global hdl_cli_opt_err
.global cli_cmd_map
.global cli_cwd_lba
.global cli_buf_raw, cli_buf_cmd, cli_buf_arg
.global cli_buf_opt, cli_buf_tmp, cli_buf_redir

.extern print_newline
.extern cmd_clear
.extern cmd_echo
.extern cmd_touch
.extern cmd_rm
.extern cmd_ls
.extern cmd_cat
.extern cmd_help
.extern cmd_mkdir

# exec_cli_cmd()
exec_cli_cmd:
  call .tok_cli_buf

  mov $cli_cmd_map, %si

.exec_cli_cmd__chk_addr_lp:
  # cond: null ? err
  mov (%si), %bx # cmd_addr
  test %bx, %bx
  jz .exec_cli_cmd__err

  add $0x02, %si # cmd_addr + 2 = cmd_str
  mov $cli_buf_cmd, %di

.exec_cli_cmd__chk_char_lp:
  # cond: char != ? skip_char_lp
  mov (%si), %al # cli_cmd_map, cmd_str
  cmp (%di), %al # cli_buf_cmd
  jne .exec_cli_cmd__skip_char_lp

  # cond: last_null ? call
  test %al, %al
  jz .exec_cli_cmd__call

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .exec_cli_cmd__chk_char_lp

.exec_cli_cmd__skip_char_lp:
  # cond: null ? skip_char_end
  mov (%si), %al # cli_cmd_map, cmd_str
  test %al, %al
  jz .exec_cli_cmd__skip_char_end

  # loop
  add $0x01, %si
  jmp .exec_cli_cmd__skip_char_lp

.exec_cli_cmd__skip_char_end:
  # loop
  add $0x01, %si # cli_cmd_map, cmd_addr
  jmp .exec_cli_cmd__chk_addr_lp

.exec_cli_cmd__call:
  call *%bx # cli_cmd_map, cmd_addr

  # done
  call .init_cli_buf_all
  mov $cli_buf_raw, %si # default
  ret

.exec_cli_cmd__err:
  call print_newline

  push $.cli_cmd_err_msg
  call print_str
  add $0x02, %sp

  call print_newline

  # done
  call .init_cli_buf_all
  mov $cli_buf_raw, %si # default
  ret

# hdl_cli_opt_err
hdl_cli_opt_err:
  push $.cli_opt_err_msg
  call print_str
  add $0x02, %sp

  call print_newline

  # done
  call .init_cli_buf_all
  mov $cli_buf_raw, %si # default
  ret

# .tok_cli_buf()
.tok_cli_buf:
  mov $cli_buf_raw, %si
  mov $cli_buf_cmd, %di

.tok_cli_buf__write_cmd_lp:
  # cond: null ? err
  mov (%si), %al # cli_buf_raw
  test %al, %al
  jz .tok_cli_buf__err

  # cond: space ? set_opt (end)
  cmp $0x20, %al # space
  jz .tok_cli_buf__set_opt

  # write
  mov %al, (%di) # cli_buf_cmd

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .tok_cli_buf__write_cmd_lp

.tok_cli_buf__set_opt:
  mov $cli_buf_opt, %di

.tok_cli_buf__chk_opt_lp:
  add $0x01, %si # cli_buf_raw, hyphen-minus or arg

  # cond: hyphen-minus != ? set_arg (end)
  mov (%si), %al # cli_buf_raw
  cmp $0x2D, %al # hyphen-minus
  jne .tok_cli_buf__set_arg

  # set opt
  add $0x01, %si # cli_buf_raw, opt_char

.tok_cli_buf__write_opt_lp:
  # cond: null ? err
  mov (%si), %al
  test %al, %al
  jz .tok_cli_buf__err

  # cond: space ? buf_opt_chk
  mov (%si), %al
  cmp $0x20, %al # space
  je .tok_cli_buf__chk_opt_lp

  # write
  mov %al, (%di) # cli_buf_opt

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .tok_cli_buf__write_opt_lp

.tok_cli_buf__set_arg:
  mov $cli_buf_arg, %di

.tok_cli_buf__write_arg_lp:
  # cond: null ? done
  mov (%si), %al
  test %al, %al
  jz .tok_cli_buf__done

  # write
  mov %al, (%di) # cli_buf_arg

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .tok_cli_buf__write_arg_lp

.tok_cli_buf__done:
  ret

.tok_cli_buf__err:
  xor %al, %al
  mov %al, (%di)
  ret

# .init_cli_buf_all()
.init_cli_buf_all:
  push $cli_buf_raw
  call .init_cli_buf
  add $0x02, %sp

  push $cli_buf_cmd
  call .init_cli_buf
  add $0x02, %sp

  push $cli_buf_arg
  call .init_cli_buf
  add $0x02, %sp

  push $cli_buf_opt
  call .init_cli_buf
  add $0x02, %sp

  push $cli_buf_tmp
  call .init_cli_buf
  add $0x02, %sp

  push $cli_buf_redir
  call .init_cli_buf
  add $0x02, %sp
  ret

# .init_cli_buf(cli_buf)
.init_cli_buf:
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  mov 4(%bp), %si

.init_cli_buf__lp:
  # cond: null ? end
  mov (%si), %al
  test %al, %al
  jz .init_cli_buf__end

  # init
  xor %al, %al
  movb %al, (%si)

  # loop
  add $0x01, %si
  jmp .init_cli_buf__lp

.init_cli_buf__end:
  pop %ax
  pop %si
  pop %bp
  ret

.section .data

# cli_cmd_map
cli_cmd_map:
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
  .word cmd_mkdir
  .asciz "mkdir"
  .word 0x00
  .asciz ""

# cli_buf_*
cli_buf_raw: .zero 0x40
cli_buf_cmd: .zero 0x20
cli_buf_arg: .zero 0x20
cli_buf_opt: .zero 0x10
cli_buf_tmp: .zero 0x20
cli_buf_redir: .zero 0x20

# cli_cwd_lba
cli_cwd_lba: .long 0x00

# *_err_msg
.cli_cmd_err_msg: .asciz "Command not found. Try \"help\" for a list of commands."
.cli_opt_err_msg: .asciz "Invalid option."
