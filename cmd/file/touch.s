# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# touch

# INDEX
# cmd_touch()

# DEPS
# cmd_touch()
#   read_block
#   write_block
#   write_dentry
#   outnl
#   cwd_lba
#   write_meta
#   free_lba

.code16
.section .text

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

  call read_block

  # set mem ptr
  mov $0x8000, %bx

.cmd_touch__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_touch__cmp_name

  # cond: null ? write_name
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_touch__write_name

  # loop
  add $0x02, %bx
  jmp .cmd_touch__find_magic_lp

.cmd_touch__cmp_name:
  # copy ptr (magic)
  mov %bx, %di

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl # name size
  add 3(%bx), %cl # padding size

  # set ptr (name)
  sub %cx, %di

  # arg
  xor %dx, %dx
  mov $argv, %si
  add $0x02, %si
  mov (%si), %dx
  mov $raw_buf, %si
  add %dx, %si

.cmd_touch__cmp_name_lp:
  # cond: 0 ? err_exist
  test %cx, %cx
  jz .cmd_touch__err_exist

  # cond: char != ? cmp_name_end
  mov (%si), %al # arg
  cmp (%di), %al # name ptr
  jne .cmd_touch__cmp_name_end

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_touch__cmp_name_lp

.cmd_touch__cmp_name_end:
  # loop
  add $0x0A, %bx
  jmp .cmd_touch__find_magic_lp

.cmd_touch__write_name:
  # arg
  mov $argv, %si
  add $0x02, %si
  mov (%si), %cx
  mov $raw_buf, %si
  add %cx, %si

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
  call write_dentry2
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

.cmd_touch__err_exist:
  call outnl

  push $.cmd_touch__err_exist_msg
  call puts
  add $0x02, %sp

  jmp .cmd_touch__done

.section .data

.cmd_touch__err_exist_msg: .asciz "Already exists."
