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
	call vga_get_curs

	# {end.done} (cursor.x == cursor.max)
	cmp (cursor+0x02), %ax
	je .done

	# right cursor
	add $0x01, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	add $0x01, %si # raw.data

.done:
	ret
