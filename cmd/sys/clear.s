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
# AL: scroll lines (0x00: clear)
# BH: (background [4-bit] << 4) + foreground [4-bit]
# CH: startY, CL: startX, DH: endY, DL: endX
#
# set cursor:
# Q: Why are DH and DL 0x00?
# A: Cursor auto-inc in _sys_tty_out.
# Prompt (kernel_prompt) is printed by handler (.hdl_kbd_enter).

.section .text
.code16
.global cmd_clear

# cmd_clear() [n_cmd_clear]
cmd_clear:
	call get_cursor
	call get_mode

	# copy end_x
	mov %ah, %dl

	call scroll_up

	xor %dx, %dx
	call set_cursor
	ret
