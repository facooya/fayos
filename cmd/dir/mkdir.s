# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make directory

# INDEX
# cmd_mkdir()

# DATA
.section .data

.exist_err_msg: .asciz "Already exists."

# TEXT
.section .text
.code16

.global cmd_mkdir

# cmd_mkdir()
cmd_mkdir:
  # prol
  push %si
  push %di
  push %bx

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

.cmd_mkdir__find_magic_lp:
  # cond: magic ? strcmp
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_mkdir__strcmp

  # cond: null ? write_name
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_mkdir__write_name

  # loop
  add $0x02, %bx
  jmp .cmd_mkdir__find_magic_lp

.cmd_mkdir__strcmp:
  # copy ptr (magic)
  mov %bx, %si

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl
  add 3(%bx), %cl

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
  # ret: ax,cx

  # ax = ret code
  # chk {strcmp}
  test %ax, %ax
  jz .hdl_exist_err

  # cx = count
  # step
  add %cx, %bx
  add $0x0A, %bx
  jmp .cmd_mkdir__find_magic_lp

.cmd_mkdir__write_name:
  # init
  mov (arg_ptr), %si
  xor %cx, %cx

.cmd_mkdir__write_name_lp:
  # cond: null ? write_name_end
  mov (%si), %al # arg
  test %al, %al
  jz .cmd_mkdir__write_name_end

  # write mem
  mov %al, (%bx)

  # loop
  add $0x01, %bx
  add $0x01, %si
  add $0x01, %cx
  jmp .cmd_mkdir__write_name_lp

.cmd_mkdir__write_name_end:
  # add null char
  add $0x01, %bx
  add $0x01, %cx # name size

  # write dentry
  push %cx
  call write_dentry
  add $0x02, %sp

  # write dentry type
  push $0x0D # directory
  call write_dentry__type
  add $0x02, %sp

  # write dentry data lba
  mov (free_lba), %ax
  mov %ax, 4(%bx)
  mov (free_lba+2), %ax
  mov %ax, 6(%bx)

  call write_block

  call write_meta

  # allocate
  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)

.cmd_mkdir__done:
  call outnl

  # epil
  pop %bx
  pop %di
  pop %si
  ret

# ERR
.hdl_exist_err:
  call outnl

  push $.exist_err_msg
  call puts
  add $0x02, %sp

  jmp .cmd_mkdir__done
