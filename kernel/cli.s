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
.global cli_buf_raw, cli_buf_cmd, cli_buf_arg
.global cli_buf_opt, cli_buf_tmp, cli_buf_redir, cli_buf_stdout

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

.tok_cli_buf__ltrim_lp:
  # cond: space != ? write_cmd_lp
  mov (%si), %al
  cmp $0x20, %al
  jnz .tok_cli_buf__write_cmd_lp

  # loop
  add $0x01, %si
  jmp .tok_cli_buf__ltrim_lp

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
  # add $0x01, %si
  mov $cli_buf_opt, %di

.tok_cli_buf__trim_opt_lp:
  # loop
  add $0x01, %si

  # cond: space != ? chk_opt_lp
  mov (%si), %al
  cmp $0x20, %al
  jne .tok_cli_buf__chk_opt_lp

  # loop
  jmp .tok_cli_buf__trim_opt_lp

.tok_cli_buf__chk_opt_lp:
  # add $0x01, %si # cli_buf_raw, hyphen-minus or arg

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

  # cond: space ? trim_opt_lp
  mov (%si), %al
  cmp $0x20, %al # space
  je .tok_cli_buf__trim_opt_lp

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

  # cond: space ? done !!! single arg
  mov (%si), %al
  cmp $0x20, %al
  # jz .tok_cli_buf__done
  jz .tok_cli_buf__trim_redir_lp

  # write
  mov %al, (%di) # cli_buf_arg

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .tok_cli_buf__write_arg_lp

.tok_cli_buf__trim_redir_lp:
  add $0x01, %si

  mov (%si), %al
  cmp $0x20, %al
  jne .tok_cli_buf__redir

  jmp .tok_cli_buf__trim_redir_lp

.tok_cli_buf__redir:
  mov (%si), %al
  cmp $0x3E, %al # greater-than
  je .tok_cli_buf__redir_gt

  jmp .tok_cli_buf__done

.tok_cli_buf__redir_gt:
  add $0x02, %si
  mov $cli_buf_redir, %di

.tok_cli_buf__redir_gt_lp:
  # cond: null ? redir_gt_end
  mov (%si), %al
  test %al, %al
  jz .tok_cli_buf__redir_gt_end

  # write
  mov %al, (%di)

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .tok_cli_buf__redir_gt_lp

.tok_cli_buf__redir_gt_end:
  # set dap
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read
  call read_block
  mov $0x8000, %si

.tok_cli_buf__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .tok_cli_buf__cmp_name

  # cond: null ? done
  mov (%si), %ax
  or 2(%si), %ax
  jz .tok_cli_buf__done

  # loop
  add $0x02, %si
  jmp .tok_cli_buf__find_magic_lp

.tok_cli_buf__cmp_name:
  # copy ptr (magic)
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # setup
  push %si # main mem ptr
  mov $cli_buf_redir, %si

.tok_cli_buf__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .tok_cli_buf__main

  # cond: char != ? skip_dentry
  mov (%si), %al # cli_buf_redir
  cmp (%di), %al # name ptr
  jne .tok_cli_buf__skip_dentry

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .tok_cli_buf__cmp_name_lp

.tok_cli_buf__skip_dentry:
  pop %si # main mem ptr

  # skip dentry [n_skip_dentry]
  add $0x0A, %si

  # loop
  jmp .tok_cli_buf__find_magic_lp

.tok_cli_buf__main:
  pop %si # main mem ptr

  # set lba
  mov 4(%si), %ax
  push %ax
  mov 6(%si), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp
  
  call read_block
  mov $0x8006, %si

  mov $cli_buf_arg, %di

.tok_cli_buf__write_data_lp:
  # cond: null ? done
  mov (%di), %al
  test %al, %al
  jz .tok_cli_buf__write_data_end

  # write
  mov %al, (%si)

  # loop
  add $0x01, %si
  add $0x01, %di
  jmp .tok_cli_buf__write_data_lp

.tok_cli_buf__write_data_end:
  call write_block

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
  .word cmd_cd
  .asciz "cd"
  .word 0x00
  .asciz ""

# cli_buf_*
cli_buf_raw: .zero 0x40
cli_buf_cmd: .zero 0x20
cli_buf_arg: .zero 0x20
cli_buf_opt: .zero 0x10
cli_buf_tmp: .zero 0x20
cli_buf_redir: .zero 0x20
cli_buf_stdout: .zero 0x40

# *_err_msg
.cli_cmd_err_msg: .asciz "Command not found. Try \"help\" for a list of commands."
.cli_opt_err_msg: .asciz "Invalid option."
