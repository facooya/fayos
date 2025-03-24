.global _start
.code16

# =============== > Kernel Start ===============

_start:
  # Print Load Message
  push $_kernel_load_msg
  call print_str
  add $0x02, %sp

  # Print Load Message 2
  push $_kernel_load_msg_2
  call print_str
  add $0x02, %sp

  call newline # kbd.inc

  # Print Prompt
  push $kernel_prompt
  call print_str
  add $0x02, %sp

  # Master Block
  call master_block # disk.inc

  # Cursor
  call set_cursor_min_x # kbd.inc

  # Key Buffer
  call set_key_buf # kbd.inc

# =============== < Kernel Start ===============
# =============== > Kernel Loop ===============

kernel_loop: # Main Loop
  mov $0x00, %ah # Read Key Press
  int $0x16

  # Keyboard, Command
  call key_manager # kbd.inc

  # Loop
  jmp kernel_loop

# =============== < Kernel Loop ===============
# =============== > Data ===============

_kernel_load_msg: .asciz "\nKernel Loaded\r\n"
_kernel_load_msg_2: .asciz "Fayos Kernel\r\n"
kernel_prompt: .asciz "fayos> "

# =============== < Data ===============
# =============== > Include ===============
# !!! -T linker.ld, .global abcde

#.include "./inc/print_test_3.inc" # print_string(msg_addr), print.inc
#.include "./inc/keyboard_test_3.inc" # key_manager(), key_buf, set_cursor_min_x(),cursor_min_x
# keyboard.inc => kbd.inc, buf.inc
#.include "./inc/command_logic_test_3.inc" # => tok.inc
#.include "./inc/command_table_test_3.inc"
#.include "./inc/command_table_test_3_1.inc" # => cmd_tbl_3_2.inc
#.include "./inc/command_file_test_3_2.inc"
#.include "./inc/sector_test_3.inc" # sector.inc => block.inc
#.include "./inc/block_test_3.inc" # => disk.inc

# -----========== > Library ==========-----

.include "./inc/lib/print_3_1.inc"

# -----========== < Library ==========-----
# -----========== > System ==========-----

.include "./inc/sys/kbd_3_1.inc"
.include "./inc/sys/disk_3_1.inc"
.include "./inc/sys/err_3_2.inc"

# -----========== < System ==========-----
# -----========== > Command ==========-----

# CLI (Command Line Interface)
.include "./inc/cmd/cli_buf_3_1.inc"
.include "./inc/cmd/cli_tok_3_1.inc"

# Command
.include "./inc/cmd/cmd_table_3_2.inc"
.include "./inc/cmd/cmd_exec_3_2.inc"

# System
.include "./inc/cmd/sys/clear_3_1.inc"
.include "./inc/cmd/sys/echo_3_1.inc"
.include "./inc/cmd/sys/help_3_1.inc"

# File
.include "./inc/cmd/file/touch_3_3.inc"
.include "./inc/cmd/file/ls_3_3.inc"
.include "./inc/cmd/file/rm_3_3.inc"
.include "./inc/cmd/file/cat_3_3.inc"

# -----========== < Command ==========-----
# =============== < Include ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
