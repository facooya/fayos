.code16

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
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
