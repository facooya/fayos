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

# cmd_cd()
cmd_cd:
  # prol
  push %si
  push %di
  push %bx

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
  mov $0x8000, %bx

.cmd_cd__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_cd__cmp_name

  # cond: null ? done
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_cd__err_no_dir

  # loop
  add $0x02, %bx
  jmp .cmd_cd__find_magic_lp

.cmd_cd__cmp_name:
  # copy ptr (magic)
  mov %bx, %di

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size

  # init {strcmp}
  sub %cx, %di
  mov (arg_ptr), %si
  # di = name ptr
  # si = arg ptr

  # call {strcmp}
  push %di
  push %si
  call strcmp
  add $0x04, %sp
  # ax = ret
  
  # chk {strcmp}
  test %ax, %ax
  jz .cmd_cd__main

.cmd_cd__cmp_name_end:
  # loop
  add $0x0A, %bx # cat.s [n_skip_dentry]
  jmp .cmd_cd__find_magic_lp

.cmd_cd__main:
  # cond: dir_type != ? err_not_dir
  movb 9(%bx), %al
  cmp $0x0D, %al
  jne .cmd_cd__err_not_dir

  # get data lba (dentry), set lba (cwd_lba)
  mov 4(%bx), %ax # low
  mov %ax, (cwd_lba)
  mov 6(%bx), %ax # high
  mov %ax, (cwd_lba+2)

.cmd_cd__done:
  call outnl

  # epil
  pop %bx
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
  mov $0x8000, %bx

  # get parent lba (dentry !!! mata_data), set lba (cwd_lba)
  mov (%bx), %ax # low
  mov %ax, (cwd_lba)
  mov 2(%bx), %ax # high
  mov %ax, (cwd_lba+2)

  jmp .cmd_cd__done

.cmd_cd__err_no_dir:
  call outnl

  push $.cd_err_no_dir_msg
  call puts
  add $0x02, %sp

  jmp .cmd_cd__done

.cmd_cd__err_not_dir:
  call outnl

  push $.cd_err_not_dir_msg
  call puts
  add $0x02, %sp

  jmp .cmd_cd__done

.section .data

.cd_err_no_dir_msg: .asciz "No found directory."
.cd_err_not_dir_msg: .asciz "Not a directory."
