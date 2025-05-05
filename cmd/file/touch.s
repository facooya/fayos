# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Touch

# INDEX
# cmd_touch()

# DATA
.section .data

.exist_err_msg: .asciz "Already exists."

# TEXT
.section .text
.code16

.global cmd_touch

# cmd_touch()
cmd_touch:
  # prol
  push %si
  push %di
  push %bx

  # set lba
  movw (cwd_lba), %ax
  push %ax
  movw (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

.cmd_touch__find_magic_lp:
  # cond: magic ? strcmp
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_touch__strcmp

  # cond: null ? write_name
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_touch__write_name

  # step
  add $0x02, %bx
  jmp .cmd_touch__find_magic_lp

.cmd_touch__strcmp:
  # copy ptr (magic)
  mov %bx, %si

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size

  # init {strcmp}
  sub %cx, %si
  mov (arg_ptr), %di

  # call {strcmp}
  push %di
  push %si
  call strcmp
  add $0x04, %sp
  # ax = ret code
  # cx = count

  # chk {strcmp}
  # cond: equal ? hdl_exist_err
  test %ax, %ax
  jz .hdl_exist_err

  # loop
  add $0x0A, %bx
  jmp .cmd_touch__find_magic_lp

.cmd_touch__write_name:
  # init
  mov (arg_ptr), %si
  xor %cx, %cx

.cmd_touch__write_name_lp:
  # cond: null ? write_name_end
  mov (%si), %al # arg
  test %al, %al
  jz .cmd_touch__write_name_end

  # write mem
  mov %al, (%bx)

  # loop
  add $0x01, %bx
  add $0x01, %si
  add $0x01, %cx
  jmp .cmd_touch__write_name_lp

.cmd_touch__write_name_end:
  # add null char
  add $0x01, %bx # mem ptr
  add $0x01, %cx # name size

  # write dentry
  push %cx
  call write_dentry
  add $0x02, %sp

  # set data lba (dentry)
  mov (free_lba), %ax
  mov %ax, 4(%bx)
  mov (free_lba+2), %ax
  mov %ax, 6(%bx)

  call write_block

  # write meta !!! TMP test
  call write_meta

  # allocate free lba, !!! TMP low only, seq: write_meta
  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)

.cmd_touch__done:
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

  jmp .cmd_touch__done
