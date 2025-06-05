# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command Line Interface for Fayos

.include "chr.s"
.section .text
.code16
.global cli_main

# cli_main()
# <REQ>
# al = ascii_code
cli_main:
	# {{{
	# {task} (ascii_code == bs)
	cmp $CHR_BS, %al
	je cli_key_bs

	# {task} (ascii_code == cr)
	cmp $CHR_CR, %al
	je cli_key_cr
	# }}}

	# {{{
	# <PRE>
	# ax = scan_code
	# {task} (scan_code == left)
	cmp $KEY_LEFT, %ax
	je cli_key_left

	# {task} (scan_code == right)
	cmp $KEY_RIGHT, %ax
	je cli_key_right

	# {task} (scan_code == up)
	cmp $KEY_UP, %ax
	je cli_key_up

	# {task} (scan_code == down)
	cmp $KEY_DOWN, %ax
	je cli_key_down
	# }}}

	# {end.call} (raw.data != null)
	mov (%si), %ah
	test %ah, %ah
	jnz .call_cli_rsh

	# {{{
	call outc

	# store chr
	mov %al, (%si) # raw.data
	add $0x01, %si

	# update len
	mov (raw_buf), %ax # raw.len
	add $0x01, %ax
	mov %ax, (raw_buf)

	# update max cursor
	mov (cursor+0x01), %al # cursor.max
	add $0x01, %al
	mov %al, (cursor+0x01)
	# }}}

.done:
	ret

.call_cli_rsh:
	call cli_rsh

	# update len
	mov (raw_buf), %ax # raw.len
	add $0x01, %ax
	mov %ax, (raw_buf)

	# update cursor max
	mov (cursor+0x01), %al # cursor.max
	add $0x01, %al
	mov %al, (cursor+0x01)

	# {step}
	add $0x01, %si # raw.data

	jmp .done
