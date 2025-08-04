# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key arrow right

.section .text
.code16
.global _key_right

# _key_right
_key_right:
	call get_cursor

	# {end.done} (cursor.x == cursor.max)
	cmp (cursor+0x01), %dl
	je .done

	# right cursor
	add $0x01, %dl # cursor.x
	call set_cursor

	# ptr
	add $0x01, %si # raw.data

.done:
	ret
