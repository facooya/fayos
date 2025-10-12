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
	call vga_get_curs

	# {end.done} (curs.x == curs.min)
	cmp (curs), %ax
	je .done

	# left curs
	sub $0x01, %ax
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# ptr
	sub $0x01, %si # raw.data

.done:
	ret
