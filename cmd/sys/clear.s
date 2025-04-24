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
#   A: Cursor auto-inc in sys_out_chr.
#      Prompt (kernel_prompt) is printed by handler (.hdl_kbd_enter).

.code16
.section .text

.global cmd_clear

# cmd_clear() [n_cmd_clear]
cmd_clear:
  # !!! HACK: sys violation
  call sys_get_cursor

  # !!! HACK: sys violation
  call sys_get_mode

  # set end_x
  mov %ah, %dl

  # !!! HACK: sys violation
  call sys_scroll_up

  xor %dx, %dx
  # !!! HACK: sys violation
  call sys_set_cursor
  ret
