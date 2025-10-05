# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Keyboard main

.include "chr.s"
.include "drv/kbd.s"
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
	# (kc == left) ? {key.left}
	cmp $KBD_KC_LEFT, %ax
	je _key_left

	# (kc == right) ? {key.right}
	cmp $KBD_KC_RIGHT, %ax
	je _key_right

	# (kc == up) ? {key.up}
	cmp $KBD_KC_UP, %ax
	je _key_up

	# (kc == down) ? {key.down}
	cmp $KBD_KC_DOWN, %ax
	je _key_down

	# (kc == num_sl) ? {key.n.sl}
	cmp $KBD_KC_NUM_SL, %ax
	je .key__num_sl

	# (kc == num_ent) ? {key.cr}
	cmp $KBD_KC_NUM_ENT, %ax
	je _key_cr

	# (kc_hi == ext) ? {done}
	cmp $KBD_KC_EXT, %ah
	je .done
	# }}}
	jmp .norm

.key__num_sl:
	# sctokc
	xor %ax, %ax
	mov $CHR_SL, %al
	jmp .norm

.norm:
	# {{{ pre-update
	# update raw_buf
	push %ax # [s.0:kc]
	add $0x01, %si # raw.data
	mov (raw_buf), %ax # raw.len
	add $0x01, %ax
	mov %ax, (raw_buf)

	# update cursor max
	mov (cursor+0x02), %ax # cursor.max
	add $0x01, %ax
	mov %ax, (cursor+0x02)
	pop %ax # [s.0:kc]
	# }}}

	# {task} (raw.data-1 != null)
	mov -0x01(%si), %ah
	test %ah, %ah
	jnz .call_kbd_rsh

	# {{{
	push %ax # [s.0:ascii]
	call vga_putc
	pop %ax # [s.0:ascii]

	# store chr
	mov %al, -0x01(%si) # raw.data
	# }}}

.done:
	ret

.call_kbd_rsh:
	call kbd_rsh
	jmp .done
