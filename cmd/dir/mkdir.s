# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make directory

# INDEX
# cmd_mkdir()

# DEPS
# cmd_mkdir()
#   set_dap_lba
#   read_block
#   write_block
#   dap

.code16
.section .text

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

  call read_block

  mov $0x8000, %bx # mem ptr

.cmd_mkdir__find_magic_lp:
  # cond: magic ? cmp_name
  mov (%bx), %ax
  cmp $0xFADE, %ax
  je .cmd_mkdir__cmp_name

  # cond: null ? write_name
  test %ax, %ax
  or 2(%bx), %ax
  jz .cmd_mkdir__write_name

  # loop
  add $0x02, %bx
  jmp .cmd_mkdir__find_magic_lp

.cmd_mkdir__cmp_name:
  # copy ptr (magic)
  #mov %si, %di
  mov %bx, %di

  # get name total size
  xor %cx, %cx
  mov 2(%bx), %cl
  add 3(%bx), %cl

  # set ptr (name)
  sub %cx, %di

  # arg
  xor %dx, %dx
  mov $argv, %si
  add $0x02, %si
  mov (%si), %dx
  mov $raw_buf, %si
  add %dx, %si

.cmd_mkdir__cmp_name_lp:
  # cond: 0 ? err_exist
  test %cx, %cx
  jz .cmd_mkdir__err_exist

  # cond: char != ? cmp_name_end
  mov (%si), %al # arg
  cmp (%di), %al # name ptr
  jne .cmd_mkdir__cmp_name_end

  # loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp .cmd_mkdir__cmp_name_lp

.cmd_mkdir__cmp_name_end:
  # loop
  add $0x0A, %bx
  jmp .cmd_mkdir__find_magic_lp

# .cmd_mkdir__find_free_lp:
#   # cond: null ? write_name
#   mov (%si), %ax
#   test %ax, %ax
#   or 2(%si), %ax
#   jz .cmd_mkdir__write_name

#   # loop
#   add $0x02, %si
#   jmp .cmd_mkdir__find_free_lp

.cmd_mkdir__write_name:
  # arg
  xor %cx, %cx
  mov $argv, %si
  add $0x02, %si
  mov (%si), %cx
  mov $raw_buf, %si
  add %cx, %si
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

.cmd_mkdir__err_exist:
  call outnl

  push $.cmd_mkdir__err_exist_msg
  call puts
  add $0x02, %sp

  jmp .cmd_mkdir__done

.section .data

.cmd_mkdir__err_exist_msg: .asciz "Already exists."
