# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Misc video library

.section .text
.code16
.global get_mode
.global scroll_up

# get_mode()
get_mode:
	call _sys_get_mode
	ret

# scroll_up()
scroll_up:
	push %bx
	call _sys_scroll_up
	pop %bx
	ret
