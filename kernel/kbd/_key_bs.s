# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key backspace

.section .text
.code16
.global _key_bs

# _key_bs()
_key_bs:
	# {end.done} (cursor.x == cursor.min)
	call get_cursor
	cmp (cursor), %dl
	je .done

	# {{{ pre-update
	# dec cursor max
	mov (cursor+0x01), %al # cursor.max
	sub $0x01, %al
	mov %al, (cursor+0x01)

	# dec raw_buf
	sub $0x01, %si # raw.data
	mov (raw_buf), %ax # raw.len
	sub $0x01, %ax
	mov %ax, (raw_buf)
	# }}}

	# {task} (raw.data+1 != null)
	mov 0x01(%si), %al
	test %al, %al
	jnz .call_kbd_lsh

	# {{{ [d_nsh]
	# left cursor [d_nsh.1]
	call get_cursor
	sub $0x01, %dl # cursor.x
	call set_cursor

	# overwrite [d_nsh.2]
	call outsp

	# left cursor [d_nsh.3]
	call set_cursor

	# {step} store null [d_nsh.4]
	xor %al, %al
	mov %al, (%si) # raw.data
	# }}}

.done:
	ret

.call_kbd_lsh:
	call kbd_lsh
	jmp .done
