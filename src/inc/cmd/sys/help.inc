.code16

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
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
