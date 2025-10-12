# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Key backspace

.section .text
.code16
.global _key_bs

# _key_bs
_key_bs:
	# {end.done} (cursor.x == cursor.min)
	call vga_get_curs
	cmp (cursor), %ax
	je .done

	# {{{ pre-update
	# dec cursor max
	mov (cursor+0x02), %ax # cursor.max
	sub $0x01, %ax
	mov %ax, (cursor+0x02)

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
	call vga_get_curs
	sub $0x01, %ax # cursor.x
	push %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# overwrite [d_nsh.2]
	mov $0x20, %al # space
	call vga_putc

	# left cursor [d_nsh.3]
	pop %ax # [s.0:curs_pos]
	push %ax
	call vga_set_curs
	add $0x02, %sp

	# {step} store null [d_nsh.4]
	xor %al, %al
	mov %al, (%si) # raw.data
	# }}}

.done:
	ret

.call_kbd_lsh:
	call kbd_lsh
	jmp .done
