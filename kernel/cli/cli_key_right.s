# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key arrow right

.section .text
.code16
.global cli_key_right

# cli_key_right()
cli_key_right:
	call sys_get_cursor

	# {end.done} (cursor.x == cursor.max)
	cmp (cursor+0x01), %dl
	je .done

	# right cursor
	add $0x01, %dl # cursor.x
	call sys_set_cursor

	# ptr
	add $0x01, %si # raw.data

.done:
	ret
