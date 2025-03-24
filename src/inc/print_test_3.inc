.code16
# =============== > Print ===============
# Macro [./print_macro.inc]
# =============== < Print ===============
# =============== > Inner Logic ===============

print_str: # Entry Point
  # Stack
  push %bp # Save Base
  mov %sp, %bp # New Base

  # Argument Setting
  mov 4(%bp), %si # [BP]: Ret Addr, [BP+2]: Save [BP], [BP+4]: Arg 1

  # Print Setting
  mov $0x0E, %ah

  # Next Step
  jmp print_str_loop

print_str_loop:
  # Compare Null
  mov (%si), %al
  test %al, %al
  jz print_str_done

  # Interrupt
  int $0x10

  # Loop
  inc %si
  jmp print_str_loop

print_str_done:
  # Stack
  pop %bp # Restore

  # Return
  ret

# =============== Print Escape ===============

# Print Escape
print_esc: # Entry Point
  push %bp
  mov %sp, %bp

  mov 4(%bp), %si

  jmp print_esc_chk_loop

# Print Escape Check Loop
print_esc_chk_loop:
  # Null ? End => Print
  mov (%si), %al
  test %al, %al
  jz print_esc_chk_end

  # Backslash ? Match
  cmp $0x5C, %al # Backslash
  jz print_esc_match

  # Loop
  inc %si
  jmp print_esc_chk_loop

print_esc_chk_end:
  # Print Setting
  mov 4(%bp), %si
  mov $0x0E, %ah

  # Start
  jmp print_esc_loop

print_esc_loop: # Print
  # Null ? Done
  mov (%si), %al
  test %al, %al
  jz print_esc_done

  # Interrupt
  int $0x10

  # Loop
  inc %si
  jmp print_esc_loop

print_esc_match:
  # [SI]: Backslash, [SI+1]: Match Byte (Match ? Set)
  inc %si
  mov (%si), %al

  # Null ? Pass
  test %al, %al
  jz print_esc_chk_end

  # n (newline) ? Set
  cmp $'n', %al
  jz print_esc_set_n

  # Continue Escape Check
  inc %si
  jmp print_esc_chk_loop

print_esc_set_n: # n: newline
  # Set Byte
  movb $0x0D, -1(%si) # CR, (Backslash => CR)
  movb $0x0A, (%si) # LF, (n => LF)

  # Continue Check
  inc %si
  jmp print_esc_chk_loop

print_esc_done:
  # Restore
  pop %bp

  # Return
  ret

# =============== < Inner Logic ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
