# === > PRIVIEW

# FUNC
# print_str(&msg)
# print_esc(&msg)

# === < PRIVIEW
# ===
# === > CODE

.code16

# -== > Print String

# print_str(&msg)
# msg: Data address
print_str:
_print_str__prol:
  push %bp
  mov %sp, %bp

  push %si
  push %ax

_print_str__out_set:
  mov 4(%bp), %si # &msg
  mov $0x0E, %ah # write (INT 0x10)

_print_str__out_lp:
  # Cond: null ? out_end
  mov (%si), %al
  test %al, %al
  jz _print_str__out_end

  # INT
  int $0x10

  # Loop: SI++
  add $0x01, %si
  jmp _print_str__out_lp

_print_str__out_end:

_print_str__epil:
  pop %ax
  pop %si
  pop %bp

_print_str__done:
  ret

# -== < Print String
# ===
# -== > Print Escape

# print_esc(&msg)
# msg: Data address
print_esc:
_print_esc__prol:
  push %bp
  mov %sp, %bp
  
  push %si
  push %ax

# --= > Out

_print_esc__out_set:
  mov 4(%bp), %si # &msg
  mov $0x0E, %ah # write (INT 0x10)

_print_esc__out_lp:
  # Cond: null ? out_end
  mov (%si), %al
  test %al, %al
  jz _print_esc__out_end

  # Cond: backslash ? esc
  cmp $0x5C, %al # 0x5C: backslash
  jz _print_esc__esc

  # INT
  int $0x10

  # Loop: SI++
  add $0x01, %si
  jmp _print_esc__out_lp

_print_esc__out_end:
  jmp _print_esc__epil

# --= < Out
# ===
# --= > Escape

_print_esc__esc:
  # Backslash next byte (Expect: esc)
  add $0x01, %si
  mov (%si), %al

  # Cond: n ? esc_n
  cmp $0x6E, %al # 0x6E: n
  jz _print_esc__esc_n

  # Else: out backslash
  mov $0x5C, %al # 0x5C: backslash
  int $0x10

  # Continue: out_lp
  jmp _print_esc__out_lp

_print_esc__esc_n: # n: Newline
  # Out newline
  mov $0x0D, %al # 0x0D: CR
  int $0x10
  mov $0x0A, %al # 0x0A: LF
  int $0x10

  # End: esc_end
  jmp _print_esc__esc_end

_print_esc__esc_end:
  # Continue: out_lp
  add $0x01, %si # Next Addr (Expect: str)
  jmp _print_esc__out_lp

# --= < Escape

_print_esc__epil:
  pop %ax
  pop %si
  pop %bp

_print_esc__done:
  ret

# -== < Print Escape
# ===
# === < CODE
# ===
# === > FACOOYA
# Copyright 2025 Facooya.
# === < FACOOYA
