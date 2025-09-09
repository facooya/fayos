# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Keyboard main

.include "chr.s"
.section .text
.code16
.global kbd_main

# kbd_main()
# <req> al = ascii_code
# <req> ax = scan_code
kbd_main:
	# {{{
	# {task} (ascii_code == bs)
	cmp $CHR_BS, %al
	je _key_bs

	# {task} (ascii_code == cr)
	cmp $CHR_CR, %al
	je _key_cr
	# }}}

	# {{{
	# {task} (scan_code == left)
	cmp $KEY_LEFT, %ax
	je _key_left

	# {task} (scan_code == right)
	cmp $KEY_RIGHT, %ax
	je _key_right

	# {task} (scan_code == up)
	cmp $KEY_UP, %ax
	je _key_up

	# {task} (scan_code == down)
	cmp $KEY_DOWN, %ax
	je _key_down
	# }}}

	# {{{ pre-update
	# update raw_buf
	push %ax
	add $0x01, %si # raw.data
	mov (raw_buf), %ax # raw.len
	add $0x01, %ax
	mov %ax, (raw_buf)

	# update cursor max
	mov (cursor+0x01), %al # cursor.max
	add $0x01, %al
	mov %al, (cursor+0x01)
	pop %ax
	# }}}

	# {task} (raw.data-1 != null)
	mov -0x01(%si), %ah
	test %ah, %ah
	jnz .call_kbd_rsh

	# {{{
	call outc2

	# store chr
	mov %al, -0x01(%si) # raw.data
	# }}}

.done:
	ret

.call_kbd_rsh:
	call kbd_rsh
	jmp .done
