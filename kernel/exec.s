# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute command and redirect

# DATA
.section .data

# cmd_map
cmd_map:
  .word cmd_clear
  .asciz "clear"
  .word cmd_echo
  .asciz "echo"
  .word cmd_touch
  .asciz "touch"
  .word cmd_touch2
  .asciz "touch2"
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

.no_cmd_err_msg: .asciz "Command not found. Try \"help\" for a list of commands."

# TEXT
.section .text
.code16

.global exec_cmd
.global cmd_map

# ENTRY
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

  # cond: ax == 1 ? done
  cmp $0x01, %ax
  je .exec_cmd__done

  call build_args

  # load argc
  mov $argc, %di
  mov (%di), %cx

  # cond: cx == 0 ? pre_done
  test %cx, %cx
  jz .exec_cmd__pre_done

  # init
  mov $raw_buf, %si
  mov $cmd_map, %di

# CHK
.exec_cmd__chk_addr_lp:
  # load
  mov (%di), %bx

  # cond: null ? hdl_no_cmd_err
  test %bx, %bx
  jz .hdl_no_cmd_err

  # char
  add $0x02, %di

.exec_cmd__chk_char_lp:
  # load
  mov (%di), %al

  # cond: al != si ? skip_char_lp
  cmp (%si), %al
  jne .exec_cmd__skip_char_lp

  # cond: null ? call
  test %al, %al
  jz .exec_cmd__call

  # step
  add $0x01, %si
  add $0x01, %di
  jmp .exec_cmd__chk_char_lp

# SKIP_CHAR
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

# CALL
.exec_cmd__call:
  # pre: bx = cmd_addr

  call *%bx

  # init and load
  mov $redir_buf, %si
  mov (%si), %al

  # cond: null != ? chk_redir_type
  test %al, %al
  jne .exec_cmd__chk_redir_type

  # done
  jmp .exec_cmd__done

# REDIR
.exec_cmd__chk_redir_type:
  # pre: al != null

  # cond: gt ? out_redir
  cmp $0x3E, %al
  je .exec_cmd__out_redir

  # done
  jmp .exec_cmd__done

.exec_cmd__out_redir:
  # !!! TODO: call redir
  # pre: al = gt

  # init
  add $0x02, %si
  mov %si, %di # redir file name

  # set lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read
  call read_block
  mov $0x8006, %bx

.exec_cmd__redir_find_magic:
  # load
  mov (%bx), %ax

  # cond: magic ? cmp_name
  cmp $0xFADE, %ax
  je .exec_cmd__redir_cmp_name

  # cond: null ? done !!! FIXME not found err
  mov (%bx), %ax
  or 2(%bx), %ax
  jz .exec_cmd__done

  # step
  add $0x02, %bx
  jmp .exec_cmd__redir_find_magic

.exec_cmd__redir_cmp_name:
  # copy ptr (magic)
  mov %bx, %si

  # get name size
  xor %cx, %cx
  mov 2(%bx), %cl # name
  add 3(%bx), %cl # padding

  # name ptr
  sub %cx, %si

  # init
  xor %dx, %dx

.exec_cmd__redir_cmp_name_lp:
  # cond: 0 ? main
  test %cx, %cx
  jz .exec_cmd__out_redir_main

  # load
  mov (%si), %al

  # cond: char != ? skip_dentry
  cmp (%di), %al
  jne .exec_cmd__redir_skip_dentry

  # step
  add $0x01, %si
  add $0x01, %di
  add $0x01, %dx
  sub $0x01, %cx
  jmp .exec_cmd__redir_cmp_name_lp

.exec_cmd__redir_skip_dentry:
  # init
  sub %dx, %si
  xor %dx, %dx

  # loop
  add $0x0A, %bx
  jmp .exec_cmd__redir_find_magic

.exec_cmd__out_redir_main:
  # set lba
  mov 4(%bx), %ax
  push %ax
  mov 6(%bx), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8006, %bx # !!! TMP

  # arg
  mov (arg_ptr), %si
  
.exec_cmd__out_redir_write:
  # load
  mov (%si), %al

  # cond: null ? done
  test %al, %al
  jz .exec_cmd__out_redir_write_end

  # store
  mov %al, (%bx)

  # step
  add $0x01, %si
  add $0x01, %bx
  jmp .exec_cmd__out_redir_write

.exec_cmd__out_redir_write_end:
  call write_block
  jmp .exec_cmd__done

# DONE
.exec_cmd__pre_done:
  call outnl

.exec_cmd__done:
  # epil
  pop %cx
  pop %bx
  pop %ax
  pop %di
  pop %si
  ret

# ERROR
.hdl_no_cmd_err:
  call outnl

  push $.no_cmd_err_msg
  call puts
  add $0x02, %sp

  call outnl

  jmp .exec_cmd__done
