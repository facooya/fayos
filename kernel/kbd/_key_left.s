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
	call get_cursor

	# {end.done} (cursor.x == cursor.min)
	cmp (cursor), %dl
	je .done

	# left cursor
	sub $0x01, %dl # cursor.x
	call set_cursor

	# ptr
	sub $0x01, %si # raw.data

.done:
	ret
