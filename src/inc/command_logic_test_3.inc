.code16
# =============== > Find Command ===============

find_cmd: # enter_key() => parse_key_buf_*() => find_cmd()
  call parse_key_buf # parse_key_buf_*(): cmd => opt => arg
  mov $cmd_table, %si # command_table.inc

find_cmd_loop: # next_cmd_exit => find_cmd_loop
  # Check Address
  mov (%si), %bx
  test %bx, %bx
  jz cmd_not_found

  # Next Logic
  jmp cmp_cmd

find_cmd_exit:
  ret

# =============== < Find Command ===============
# =============== > Parse Key Buffer ===============

parse_key_buf: # Entry Point
  mov $key_buf, %si # Main Buffer
  jmp parse_key_buf_cmd

# ==========----- > Parse Command -----==========
# !!!!! Verify First is Char OR Number

parse_key_buf_cmd:
  mov $cmd_buf, %di

parse_key_buf_cmd_loop:
  # Compare Null
  mov (%si), %al
  test %al, %al
  jz parse_key_buf_cmd_done

  # Compare Space
  cmp $0x20, %al
  jz parse_verify_key_buf_opt # Parse opt => arg

  # Save cmd_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp parse_key_buf_cmd_loop

parse_key_buf_cmd_done:
  # Add Null
  xor %al, %al
  mov %al, (%di)

  # Return
  ret

# ==========----- < Parse Command -----==========
# ==========----- > Parse Option -----==========

# =====---------- > Verify Option ----------=====

parse_verify_key_buf_opt:
  # [SI]: Space, [SI+1]: Hyphen-Minus OR Argument Byte
  inc %si

  # Compare Hyphen-Minus
  mov (%si), %al
  cmp $0x2D, %al
  jz parse_key_buf_opt

  # Not Option
  jmp parse_key_buf_arg

# =====---------- < Verify Option ----------=====
# Opt: -a -b -c, -abc = opt_buf: abc
parse_key_buf_opt:
  # [SI]: Hyphen-Minus, [SI+1]: Option Byte
  inc %si
  mov $opt_buf, %di

parse_key_buf_opt_loop:
  # Compare Null, Error => Exit
  mov (%si), %al
  test %al, %al
  jz parse_key_buf_opt_exit

  # Compare Space, Safe => Done => Next
  mov (%si), %al
  cmp $0x20, %al
  jz parse_verify_key_buf_opt_is_opt # Check Point 

  # Save: opt_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp parse_key_buf_opt_loop

parse_verify_key_buf_opt_is_opt:
  # [SI]: Space, [SI+1]: Hyphen-Minus OR Argument Byte
  inc %si

  # Compare Hyphen-Minus
  mov (%si), %al
  cmp $0x2D, %al
  jz parse_verify_key_buf_opt_true

  # Next Point, Option Done
  jmp parse_key_buf_opt_done # Next Point

parse_verify_key_buf_opt_true:
  # [SI]: Hyphen-Minus, [SI+1]: Option Byte
  # [DI](opt_buf): Already Empty Byte

  # Continue Loop
  inc %si
  jmp parse_key_buf_opt_loop

parse_key_buf_opt_exit:
  call init_opt_buf
  ret

parse_key_buf_opt_done:
  # Add Null Byte: (opt_buf) + (Null)
  xor %al, %al
  mov %al, (%di)

  # Next Point
  jmp parse_key_buf_arg

# ==========----- < Parse Option -----==========
# ------------------------------

parse_key_buf_arg:
  #inc %si # save_opt_buf_done
  mov $arg_buf, %di

parse_key_buf_arg_loop:
  # Compare Null
  mov (%si), %al
  test %al, %al
  jz parse_key_buf_arg_done

  # Save arg_buf
  mov %al, (%di)

  # Loop
  inc %si
  inc %di
  jmp parse_key_buf_arg_loop

parse_key_buf_arg_done:
  #PRINT arg_buf # print.inc

  #jmp parse_key_buf_done
  ret

# =============== < Seperate Key Buffer ===============
# =============== > Compare Command ===============

cmp_cmd:
  add $0x02, %si # cmd_table: Char Address
  #call set_key_buf
  mov $cmd_buf, %di

cmp_cmd_loop:
  # Compare Command Char
  mov (%si), %al
  cmp (%di), %al
  jne cmp_cmd_exit

  # Command Found
  test %al, %al
  jz call_cmd_func

  # Loop
  inc %si
  inc %di
  jmp cmp_cmd_loop

cmp_cmd_exit:
  jmp next_cmd # Next Command

# --------------- Call Command Function ---------------
call_cmd_func:
  call *%bx # command_table.inc: cmd_table Command Address
  jmp find_cmd_exit # Exit

# =============== < Compare Command ===============
# =============== > Skip Command ===============

next_cmd: # Entry Point
next_cmd_loop:
  # Compare
  mov (%si), %al
  test %al, %al
  jz next_cmd_exit

  # Loop
  inc %si
  jmp next_cmd_loop

next_cmd_exit:
  inc %si # Next Command Address
  jmp find_cmd_loop
  
# =============== < Skip Command ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
