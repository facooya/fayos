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
# <req> ax = extend_key
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
	cmp $0xE06B, %ax
	je _key_left

	# {task} (scan_code == right)
	cmp $0xE074, %ax
	je _key_right

	# {task} (scan_code == up)
	cmp $0xE075, %ax
	je _key_up

	# {task} (scan_code == down)
	cmp $0xE072, %ax
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
	mov (cursor+0x02), %ax # cursor.max
	add $0x01, %ax
	mov %ax, (cursor+0x02)
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
