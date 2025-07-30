# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear display current line

.section .text
.code16
.global clear_line_disp

# clear_line_disp
clear_line_disp:
	push %bx

	call _sys_get_cursor
	# dx = current_pos

	call _sys_get_mode
	mov %ah, %dl # end_x

	xor %cx, %cx # start_pos
	mov %dh, %ch # start_y
	call _sys_scroll_up

	xor %dl, %dl # end_x
	call _sys_set_cursor

	pop %bx
	ret
