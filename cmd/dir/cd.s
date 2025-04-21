# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Change directory

# INDEX
# cmd_cd()

# DEPS
# cmd_cd()
#   set_dap_lba
#   read_block
#   dap
#   cwd_lba

.code16
.section .text

.global cmd_cd

.extern print_newline
.extern set_dap_lba
.extern read_block
.extern dap
.extern cwd_lba

# cmd_cd()
cmd_cd:
  # prol
  push %si
  push %di
  push %ax
  push %cx

  # arg
  mov $argv, %di
  add $0x02, %di
  mov (%di), %cx
  mov $raw_buf, %di
  add %cx, %di

  # load
  mov (%di), %ax

  # cond: period ? back
  cmp $0x2E2E, %ax # period
  jz .cmd_cd__back

  # set lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # set mem ptr
  mov $0x8000, %si

.cmd_cd__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je .cmd_cd__cmp_name

  # cond: null ? done
  test %ax, %ax
  or 2(%si), %ax
  jz .cmd_cd__err_no_dir

  # loop
  add $0x02, %si
  jmp .cmd_cd__find_magic_lp

.cmd_cd__cmp_name:
  # copy ptr (magic)
  mov %si, %di

  # get name total size
  xor %cx, %cx
  mov 2(%si), %cl # name size
  add 3(%si), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # setup
  push %si # main mem ptr !!! danger

  # arg
  mov $argv, %si
  add $0x02, %si
  mov (%si), %cx
  mov $raw_buf, %si
  add %cx, %si

.cmd_cd__cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .cmd_cd__main

  # cond: char != ? cmp_name_end
  mov (%si), %al # arg
  cmp (%di), %al # name ptr
  jne .cmd_cd__cmp_name_end

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_cd__cmp_name_lp

.cmd_cd__cmp_name_end:
  pop %si # main mem ptr

  # loop
  add $0x0A, %si # cat.s [n_skip_dentry]
  jmp .cmd_cd__find_magic_lp

.cmd_cd__main:
  pop %si # main mem ptr

  # cond: dir_type != ? err_not_dir
  movb 9(%si), %al
  cmp $0x0D, %al
  jne .cmd_cd__err_not_dir

  # get data lba (dentry), set lba (cwd_lba)
  mov 4(%si), %ax # low
  mov %ax, (cwd_lba)
  mov 6(%si), %ax # high
  mov %ax, (cwd_lba+2)

.cmd_cd__done:
  call print_newline

  # epil
  pop %cx
  pop %ax
  pop %di
  pop %si
  ret

.cmd_cd__back:
  # !!! meta_data
  # set meta lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # set mem ptr
  mov $0x8000, %si

  # get parent lba (dentry !!! mata_data), set lba (cwd_lba)
  mov (%si), %ax # low
  mov %ax, (cwd_lba)
  mov 2(%si), %ax # high
  mov %ax, (cwd_lba+2)

  jmp .cmd_cd__done

.cmd_cd__err_no_dir:
  call print_newline

  push $.cd_err_no_dir_msg
  call print_str
  add $0x02, %sp

  jmp .cmd_cd__done

.cmd_cd__err_not_dir:
  call print_newline

  push $.cd_err_not_dir_msg
  call print_str
  add $0x02, %sp

  jmp .cmd_cd__done

.section .data

.cd_err_no_dir_msg: .asciz "No found directory."
.cd_err_not_dir_msg: .asciz "Not a directory."
