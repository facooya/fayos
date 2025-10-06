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
# <req> al = kc
kbd_main:
	# {{{
	# (kc == bs) ? {key.bs}
	cmp $CHR_BS, %al
	je _key_bs

	# (kc == cr) ? {key.cr}
	cmp $CHR_CR, %al
	je _key_cr
	# }}}

	# TODO: check (kc >= 0x80)
	# {{{
	# Arrow
	# (kc == left) ? {key.left}
	cmp $KBD_KC_LEFT, %al
	je _key_left
	# (kc == right) ? {key.right}
	cmp $KBD_KC_RIGHT, %al
	je _key_right
	# (kc == up) ? {key.up}
	cmp $KBD_KC_UP, %al
	je _key_up
	# (kc == down) ? {key.down}
	cmp $KBD_KC_DOWN, %al
	je _key_down

	# Numpad
	# (kc == num_sl) ? {key.n.sl}
	cmp $KBD_KC_NUM_SL, %al
	je .key__num_sl
	# (kc == num_ent) ? {key.n.cr}
	cmp $KBD_KC_NUM_ENT, %al
	je _key_cr

	# Special
	# (kc == tab) ? {key.tab}
	cmp $KBD_KC_TAB, %al
	je .done
	# (kc == esc) ? {key.esc}
	cmp $KBD_KC_ESC, %al
	je .done

	# FN
	# (kc == f1) ? {key.f1}
	cmp $KBD_KC_F1, %al
	je .done
	# (kc == f2) ? {key.f2}
	cmp $KBD_KC_F2, %al
	je .done
	# }}}
	jmp .norm

.key__num_sl:
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
	push %ax # [s.0:kc]
	call vga_putc
	pop %ax # [s.0:kc]

	# store chr
	mov %al, -0x01(%si) # raw.data
	# }}}

.done:
	ret

.call_kbd_rsh:
	call kbd_rsh
	jmp .done
