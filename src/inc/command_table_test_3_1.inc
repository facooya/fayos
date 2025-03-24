.code16
# =============== > Commands ===============
# -----========== > Command Not Found ==========-----

cmd_not_found:
  # Output
  call newline

  # Print Error Message
  push $cmd_not_found_msg
  call print_str
  add $0x02, %sp

  call newline
  
  # Return
  ret

# -----========== < Command Not Found ==========-----
# -----========== > Command Help ==========-----

cmd_help:
  mov $cmd_table, %si
  mov $tmp_buf, %di

cmd_help_check_cmd_addr:
  # Compare Address Null
  mov (%si), %bx
  test %bx, %bx
  jz cmd_help_exit

  # This Command Char
  add $0x02, %si # Addr Cmd Char
  jmp cmd_help_loop_cmd_char

cmd_help_loop_cmd_char:
  # Compare Char Null
  mov (%si), %al
  test %al, %al
  jz cmd_help_output

  # Save cmd_char => tmp_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp cmd_help_loop_cmd_char

cmd_help_output:
  # Next Point [SI], [DI]
  inc %si
  inc %di

  # Last Null [DI]
  xor %al, %al
  mov %al, (%di)

  # Newline
  call newline

  # print_str() AND init_tmp_buf() Using [SI]
  push %si

  # Print tmp_buf
  push $tmp_buf # Output tmp_buf
  call print_str
  add $0x02, %sp

  call init_tmp_buf # Init tmp_buf
  pop %si

  # Set tmp_buf
  mov $tmp_buf, %di

  # Next Command Check
  jmp cmd_help_check_cmd_addr

cmd_help_exit:
  # Newline
  call newline

  # Return
  ret

# -----========== < Command Help ==========-----
# -----========== > Command Clear ==========-----

cmd_clear:
  # Get Cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10 # [DH] => [DH](Y2)

  # Get Video Mode
  mov $0x0F, %ah # return X => [AH]
  int $0x10
  mov %ah, %dl # videoX => [DL](X2)

  # Scroll Up
  mov $0x06, %ah # Scroll Up
  mov $0x00, %al # Scroll Lines, 0x00: Clear
  mov $0x07, %bh # [BH] = (BG[4-bits] << 4) + FG[4-bits], 0x0: Black, 0x7: Light Gray
  mov $0x00, %ch # Y1
  mov $0x00, %cl # X1
  #mov $0x00, %dh # Y2
  #mov $0x00, %dl # X2
  int $0x10

  # Set Cursor
  mov $0x02, %ah
  mov $0x00, %bh
  mov $0x00, %dh
  mov $0x00, %dl
  int $0x10

  # Return
  ret

# -----========== < Command Clear ==========-----
# -----========== > Command (echo) ==========-----

cmd_echo: # Entry Point
  jmp _cmd_echo__chk_opt

# ----------===== > (echo) Option Check =====----------

_cmd_echo__chk_opt:
  # Set Address
  mov $opt_buf, %si
  mov $_cmd_echo__flag, %bx

_cmd_echo__chk_opt_loop:
  # Null ? End => Run
  mov (%si), %al
  test %al, %al
  jz _cmd_echo__chk_opt_end

  # Set Flag
  jmp _cmd_echo__set_flag

_cmd_echo__chk_opt_end:
  jmp _cmd_echo__run

# ----------===== < (echo) Option Check =====----------
# ----------===== > (echo) Flag =====----------

_cmd_echo__set_flag: # Set Flag
  # e ? Set e
  cmp $'e', %al
  jz _cmd_echo__set_flag_e

  # End e
  jmp _cmd_echo__set_flag_e_end

_cmd_echo__set_flag_e: # Set e
  # Set Flag, 0: e
  btsw $0x0, (%bx)

  # Loop
  inc %si
  jmp _cmd_echo__chk_opt_loop

_cmd_echo__set_flag_e_end: # End e
  # n ? Set n
  cmp $'n', %al
  jz _cmd_echo__set_flag_n

  # End n
  jmp _cmd_echo__set_flag_n_end

_cmd_echo__set_flag_n: # Set n
  # Set Flag, 1: n
  btsw $0x1, (%bx)
  
  # Loop
  inc %si
  jmp _cmd_echo__chk_opt_loop

_cmd_echo__set_flag_n_end: # End n
  # Option Error
  jmp cmd_echo_opt_err

# ----------===== < (echo) Flag =====----------
# ----------===== > (echo) Run =====----------

_cmd_echo__run:
  # Newline
  call newline

  # Flag e ? Run e
  btw $0x0, (%bx)
  jc _cmd_echo__run_e

  # Print arg_buf
  push $arg_buf
  call print_str
  add $0x02, %sp

  # e Skip
  jmp _cmd_echo__run_e_end

_cmd_echo__run_e: # Run e
  # Print Escape arg_buf
  push $arg_buf
  call print_esc
  add $0x02, %sp

  # e End
  jmp _cmd_echo__run_e_end

_cmd_echo__run_e_end: # e End
  # Flag n ? Run n
  btw $0x1, (%bx)
  jc _cmd_echo__run_n

  # Newline
  call newline

  # n Skip
  jmp _cmd_echo__run_n_end

_cmd_echo__run_n: # Run n
  # n End
  jmp _cmd_echo__run_n_end

_cmd_echo__run_n_end: # n End
  # Init Flag
  xor %ax, %ax
  mov %ax, (%bx)

  # Return
  ret

# ----------===== < (echo) Run =====----------

cmd_echo_opt_err: # Option Error
  # Error Option
  call newline
  mov $0x0E, %ah
  mov (%si), %al # [SI]: Option Byte
  int $0x10
  mov $0x3A, %al # Colon
  int $0x10
  mov $0x20, %al # Space
  int $0x10

  # Print Option Error Message
  push $opt_err_msg
  call print_str
  add $0x02, %sp

  call newline

  # Return
  ret

# -----========== < Command (echo) ==========-----

cmd_time:
  ret

# cmd_kernel_color, Time
# cmd_file mv cp

# --------------- Command Table ---------------

cmd_table:
  .word cmd_clear
  .asciz "clear"
  .word cmd_echo
  .asciz "echo"
  .word cmd_touch
  .asciz "touch"
  .word cmd_rm
  .asciz "rm"
  .word cmd_read
  .asciz "read"
  .word cmd_ls
  .asciz "ls"
  .word cmd_cat
  .asciz "cat"
  .word cmd_help
  .asciz "help"
  .word 0x00
  .asciz ""

# =============== < Commands ===============
# =============== > Data ===============

cmd_not_found_msg: .asciz "Command not found. Try \"help\" for a list of commands."
opt_err_msg: .asciz "Invalid option."

_cmd_echo__flag: .word 0x00 # 0: e, 1: n

# =============== < Data ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
