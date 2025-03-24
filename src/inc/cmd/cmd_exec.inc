# =============== > PREVIEW ===============

# FUNC
# cmd_exec()

# DEPS
# /cmd/cmd_table.inc (DATA: cmd_table)
# /lib/buf.inc (DATA: cmd_buf)
# /sys/err.inc (LABEL: err_cmd)

# =============== < PREVIEW ===============
# =============== > CODE ===============

.code16

# -----========== > Process ==========-----

cmd_exec:
  #call parse_key_buf # tok.inc

  mov $cmd_table, %si

_cmd_exec__chk_addr:
  # Null ? not_found
  mov (%si), %bx
  test %bx, %bx
  jz err_cmd # ref: err.inc

_cmd_exec__cmp_cmd:
  add $0x02, %si # Command Char
  mov $cmd_buf, %di

_cmd_exec__cmp_cmd_lp:
  # Char != : next_lp
  mov (%si), %al
  cmp (%di), %al
  jne _cmd_exec__next_lp

  # Found
  test %al, %al
  jz _cmd_exec__call

  # Loop
  add $0x01, %si
  add $0x01, %di
  jmp _cmd_exec__cmp_cmd_lp

_cmd_exec__next_lp:
  # Char
  mov (%si), %al
  test %al, %al
  jz _cmd_exec__next_end

  # Loop
  add $0x01, %si
  jmp _cmd_exec__next_lp

_cmd_exec__next_end:
  add $0x01, %si
  jmp _cmd_exec__chk_addr

_cmd_exec__call:
  call *%bx # Call

_cmd_exec__done:
  ret

# -----========== < Process ==========-----
# =============== < CODE ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
