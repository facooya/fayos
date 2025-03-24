# Require [./print.inc]
# Print
.macro PRINT arg
  push $\arg
  call print_str
  add $0x02, %sp
.endm

# Print Escape
.macro PRINT_ESC arg
  push $\arg
  call print_esc
  add $0x02, %sp
.endm

# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
