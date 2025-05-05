# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Change directory

# INDEX
# cmd_cd()

# DATA
.section .data

.no_dir_err_msg: .asciz "No found directory."
.not_dir_err_msg: .asciz "Not a directory."

# TEXT
.section .text
.code16

.global cmd_cd

# ENTRY
# cmd_cd()
cmd_cd:
  # prol
  push %si
  push %di
  push %bx

  # arg
  mov (arg_ptr), %si

  # load
  mov (%si), %ax

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

  # read block
  call read_block
  mov $0x8000, %bx

.cmd_cd__find_magic_lp:
  # cond: magic ? strcmp
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_cd__strcmp

  # cond: null ? hdl_no_dir_err
  test %ax, %ax
  or 2(%bx), %ax
  jz .hdl_no_dir_err

  # step
  add $0x02, %bx
  jmp .cmd_cd__find_magic_lp

.cmd_cd__strcmp:
  # copy ptr (magic)
  mov %bx, %si

  # get total name size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size
  # cx = total name size

  # init {strcmp}
  sub %cx, %si
  mov (arg_ptr), %di
  # si = file name ptr
  # di = arg ptr

  # call {strcmp}
  push %di
  push %si
  call strcmp
  add $0x04, %sp
  # ret: ax, cx
  
  # ax = 0: e, 1: ne
  # chk {strcmp}
  test %ax, %ax
  jz .cmd_cd__main

  # cx = count
  # step {magic}
  add %cx, %bx
  add $0x0A, %bx # cat.s [n_skip_dentry]
  jmp .cmd_cd__find_magic_lp

.cmd_cd__main:
  # cond: dir_type != ? hdl_not_dir_err
  mov 9(%bx), %al
  cmp $0x0D, %al
  jne .hdl_not_dir_err

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

# BACK
.cmd_cd__back:
  # !!! meta_data
  # set meta lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

  # get parent lba (dentry !!! mata_data), set lba (cwd_lba)
  mov (%bx), %ax # low
  mov %ax, (cwd_lba)
  mov 2(%bx), %ax # high
  mov %ax, (cwd_lba+2)

  jmp .cmd_cd__done

# ERR
.hdl_no_dir_err:
  call outnl

  push $.no_dir_err_msg
  call puts
  add $0x02, %sp

  jmp .cmd_cd__done

.hdl_not_dir_err:
  call outnl

  push $.not_dir_err_msg
  call puts
  add $0x02, %sp

  jmp .cmd_cd__done
