.code16
# =============== > Commands ===============
# -----========== > Command Not Found ==========-----

cmd_not_found:
  # Output
  call newline
  PRINT cmd_not_found_msg
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

  # PRINT() AND init_tmp_buf() Using [SI]
  push %si
  PRINT tmp_buf # Output tmp_buf
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

  # Print
  PRINT arg_buf

  # e Skip
  jmp _cmd_echo__run_e_end

_cmd_echo__run_e: # Run e
  # Print
  PRINT_ESC arg_buf

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

  # Error Message
  PRINT opt_err_msg
  call newline

  # Return
  ret

# -----========== < Command (echo) ==========-----
# -----========== > Command (touch) ==========-----
cmd_touch:
_cmd_touch__sector: # ST: Sector Table
  # Set DAP
  mov $0x10, %ax
  mov %ax, dap+8

  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Set SI
  mov $0x8000, %si
  mov $0x20, %cx

_cmd_touch__sector_loop:
  # Null ? End
  movw (%si), %ax
  test %ax, %ax
  jz _cmd_touch__sector_end

  # Loop
  add $0x02, %si
  inc %cx
  jmp _cmd_touch__sector_loop

_cmd_touch__sector_end:
  # Sector Table
  mov %si, %bx
  movw %cx, (%bx)

  # Disk Write
  clc
  mov $0x43, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc disk_err

_cmd_touch__file_entry:
  # Set DAP
  mov $0x11, %ax
  mov %ax, dap+8

  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Set SI
  mov $0x8000, %si

_cmd_touch__file_entry_loop:
  # Null ? End
  mov (%si), %al
  test %al, %al
  jz _cmd_touch__file_entry_end

  # Loop
  add $0x40, %si
  jmp _cmd_touch__file_entry_loop

_cmd_touch__file_entry_end:


_cmd_touch__mem:
  # Memory
  mov %si, %bx
  mov $arg_buf, %di

_cmd_touch__mem_loop:
  # Null ? End
  mov (%di), %al
  test %al, %al
  jz _cmd_touch__mem_loop_end

  # Write
  mov %al, (%si)

  # Loop
  inc %di
  inc %si
  jmp _cmd_touch__mem_loop

_cmd_touch__mem_loop_end:
  movw %cx, 34(%bx)
  movb $0x0F, 36(%bx)

_cmd_touch__run:
  # Disk Write
  clc
  mov $0x43, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  call newline

_cmd_touch__run_end:
  # Return
  ret

# -----========== < Command (touch) ==========-----
# -----========== > Command (ls) ==========-----
cmd_ls:
_cmd_ls__run:
  # Current Directory !!!

  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Newline
  call newline

  # Ready
  mov $0x8000, %bx
  mov %bx, %si
  mov $0x0E, %ah

_cmd_ls__run_loop:
  # Null ? End
  mov (%si), %al
  test %al, %al
  jz _cmd_ls__run_loop_end

  # Print
  int $0x10

  # Loop
  inc %si
  jmp _cmd_ls__run_loop

_cmd_ls__run_loop_end:
  # Next
  add $0x40, %bx
  mov %bx, %si

  # Space Add
  mov $0x20, %al
  int $0x10
  int $0x10

  # !Null ? Loop
  mov (%si), %al
  test %al, %al
  jnz _cmd_ls__run_loop

  # Newline
  call newline

  # Return
  ret
  
# -----========== < Command (ls) ==========-----
# -----========== > Command (rm) ==========-----

cmd_rm:
_cmd_rm__run:
  # Remov Arg !!!!!!

  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  mov $0x8000, %si

_cmd_rm__run_loop:
  # Null ? End
  mov (%si), %al
  test %al, %al
  jz _cmd_rm__run_end

  # Init
  xor %al, %al
  mov %al, (%si)

  # Loop
  inc %si
  jmp _cmd_rm__run_loop

_cmd_rm__run_end:
  # Disk Write
  clc
  mov $0x43, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Newline
  call newline

  # Return
  ret

# -----========== < Command (rm) ==========-----

cmd_read:
  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Char Read
  mov $0x8000, %si
  mov $0x0E, %ah
  mov (%si), %al
  int $0x10

  # Return
  ret


# -----========== < Command () ==========-----

disk_err:
  call newline
  PRINT disk_err_msg
  call newline
  ret

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
  .word cmd_help
  .asciz "help"
  .word 0x00
  .asciz ""

# =============== < Commands ===============
# =============== > Data ===============

cmd_not_found_msg: .asciz "Command not found. Try \"help\" for a list of commands."
opt_err_msg: .asciz "Invalid option."
disk_err_msg: .asciz "Disk Error."

_cmd_echo__flag: .word 0x00 # 0: e, 1: n

_cmd_touch__dap:
  .byte 0x10
  .byte 0x00
  .word 0x01
  .long 0x00008000
  .quad 0x11

# File Entry [64 Bytes]
# Name: 32 Bytes
# Size: 2 Bytes, Byte
# Sector: 2 Bytes, Sector Start
# Attr: 1 Bytes, 0x0F: Normal, 0x0E: Execute, 0x0D: Directory
# Align: 1 Bytes
# Reserved: 26 Bytes

# Temporary
# Sector Table: 0x10
# Sector File Entry: 0x11
# Sector Data: Start 0x12

# Sector Data: 0x2000


# Master Sector
# Last Free Sector: 4 Bytes
# Next Free Sector: 4 Bytes
# Delete Sector List: 4 Bytes
# ...

# File Entry [Min: 12 Bytes - Max: 512 Bytes]
# Name: 4 - 504 Bytes
# Name Align: 1 - 2 Byte
# File Type: 2 Bytes, 0x000F: File, 0x000E: Execute, 0x000D: Directory, 0x00DE: Delete
# Sector List: 4 Bytes

# Sector List
# Data Sector: 4 Bytes
# ...

# Data Sector (Directory)
# File Entry
# ...

# Data Sector (File)
# Data
# ...

# Temporary
# Master Sector: 0x10
# DAP Start: 0x11

# =============== < Data ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
