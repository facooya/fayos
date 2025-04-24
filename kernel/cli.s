# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Refer redir

.code16
.section .text

# hdl_cli_opt_err
hdl_cli_opt_err:
  push $.cli_opt_err_msg
  call puts
  add $0x02, %sp

  call outnl

  # done
  call .init_cli_buf_all
  mov $raw_buf, %si # default
  ret

# Reference
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

.section .data

# *_err_msg
.cli_opt_err_msg: .asciz "Invalid option."
