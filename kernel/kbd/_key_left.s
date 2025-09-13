# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key arrow left

.section .text
.code16
.global _key_left

# _key_left
_key_left:
	call get_cursor2

	# {end.done} (cursor.x == cursor.min)
	cmp (cursor), %ax
	je .done

	# left cursor
	sub $0x01, %ax
	push %ax
	call set_cursor2
	add $0x02, %sp

	# ptr
	sub $0x01, %si # raw.data

.done:
	ret
