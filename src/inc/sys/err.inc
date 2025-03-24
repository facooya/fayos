# =============== > PRIVIEW ===============

# LABEL
# err_cmd
# err_opt
# err_disk

# DEPS
# /sys/kbd.inc (FUNC: newline())
# /lib/print.inc (FUNC: print_str(msg))

# =============== < PRIVIEW ===============
# =============== > CODE ===============

.code16

# -----========== > Command ==========-----

err_cmd:
  call newline # kbd.inc

  # Print
  push $_err_cmd__msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc
  ret

# -----========== < Command ==========-----
# -----========== > Option ==========-----

err_opt:
  # Print
  push $_err_opt__msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc
  ret

# -----========== < Option ==========-----
# -----========== > Disk ==========-----

err_disk:
  call newline # kbd.inc

  # Print
  push $_err_disk__msg
  call print_str # print.inc
  add $0x02, %sp

  call newline # kbd.inc
  ret

# -----========== < Disk ==========-----

# =============== < CODE ===============
# =============== > DATA ===============

_err_cmd__msg: .asciz "Command not found. Try \"help\" for a list of commands."
_err_opt__msg: .asciz "Invalid option."
_err_disk__msg: .asciz "Disk Error."

# =============== < DATA ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
