.code16

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
  jmp _cmd_echo__err_opt

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

_cmd_echo__err_opt: # Error Option
  # Error Option
  call newline

  # Print error option byte
  mov $0x0E, %ah
  mov (%si), %al # [SI]: Option Byte
  int $0x10
  mov $0x3A, %al # Colon
  int $0x10
  mov $0x20, %al # Space
  int $0x10

  # Error
  jmp err_opt # ref: err.inc

# -----========== < Command (echo) ==========-----
# =============== > Data ===============

_cmd_echo__flag: .word 0x00 # 0: e, 1: n

# =============== < Data ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
