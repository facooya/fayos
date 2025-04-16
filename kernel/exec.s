# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute command

.code16
.section .text

.global exec_cmd
.global cmd_map

.extern raw_buf
.extern argv
.extern argc

# exec_cmd()
exec_cmd:
  # prol
  push %si
  push %di
  push %ax
  push %bx
  push %cx

  # tok
  call trim_raw
  call split_raw
  call build_args

  # init
  mov $raw_buf, %si
  mov $cmd_map, %di

  # mov $argc, %cx
  # mov (%cx), %cx

  # cond: argc == 0 ? done
  # test %cx, %cx
  # jz .exec_cmd__done

.exec_cmd__chk_addr_lp:
  # load
  mov (%di), %bx

  # cond: null ? err
  test %bx, %bx
  jz .exec_cmd__err

  # char
  add $0x02, %di

.exec_cmd__chk_char_lp:
  # load
  mov (%di), %al

  # !!! DEBUG
  mov $0x0E, %ah
  int $0x10
  push %ax
  mov (%si), %al
  int $0x10
  pop %ax

  # cond: al != si ? skip_char_lp
  cmp (%si), %al
  jne .exec_cmd__skip_char_lp

  # cond: null ? call
  test %al, %al
  jz .exec_cmd__call

  # !!! DEBUG
  mov $0x0E, %ah
  mov $'A', %al
  int $0x10

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .exec_cmd__chk_char_lp

.exec_cmd__skip_char_lp:
  # load
  mov (%di), %al

  # cond: null ? skip_char_end
  test %al, %al
  jz .exec_cmd__skip_char_end

  # step
  add $0x01, %di
  jmp .exec_cmd__skip_char_lp

.exec_cmd__skip_char_end:
  # step
  mov $raw_buf, %si
  add $0x01, %di
  jmp .exec_cmd__chk_addr_lp

.exec_cmd__call:
  # bx = cmd_addr
  call *%bx

.exec_cmd__done:
  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  ret

.exec_cmd__err:
  call print_newline

  push $.cmd_err_msg
  call print_str
  add $0x02, %sp

  call print_newline

  jmp .exec_cmd__done

.section .data

# cmd_map
cmd_map:
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

.cmd_err_msg: .asciz "Command not found. Try \"help\" for a list of commands."
