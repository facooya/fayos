# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# clear

# INDEX
# cmd_clear()

# NOTE
# [n_cmd_clear]
# get cursor: return endY => DH
# get video mode: return endX => AH
# scroll up: set
#   AL: scroll lines (0x00: clear)
#   BH: (background [4-bit] << 4) + foreground [4-bit]
#   CH: startY, CL: startX, DH: endY, DL: endX
# set cursor:
#   Q: Why are DH and DL 0x00?
#   A: Cursor auto-inc in print_str.
#      Prompt (kernel_prompt) is printed by handler (.hdl_kbd_enter).

.code16
.section .text

.global cmd_clear

# cmd_clear() [n_cmd_clear]
cmd_clear:
  # prol
  push %ax
  push %bx
  push %cx
  push %dx

  # get cursor
  mov $0x03, %ah
  mov $0x00, %bh
  int $0x10

  # get video mode
  mov $0x0F, %ah
  int $0x10

  # set endX
  mov %ah, %dl

  # scroll up
  mov $0x06, %ah
  mov $0x00, %al
  mov $0x07, %bh # 0x00 (black), 0x07 (light gray)
  mov $0x00, %ch 
  mov $0x00, %cl
  int $0x10

  # set cursor
  mov $0x02, %ah
  mov $0x00, %bh
  mov $0x00, %dh
  mov $0x00, %dl
  int $0x10

  # epil
  pop %dx
  pop %cx
  pop %bx
  pop %ax
  ret
