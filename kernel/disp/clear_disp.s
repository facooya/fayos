# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear display

.section .text
.code16
.global clear_disp

# clear_disp()
clear_disp:
	push %bx

	call get_cursor
	# dx = current_pos

	call _sys_get_mode
	mov %ah, %dl # vid_end_x

	xor %cx, %cx
	call _sys_scroll_up

	xor %dx, %dx # cursor(0,0)
	call set_cursor

	pop %bx
	ret
