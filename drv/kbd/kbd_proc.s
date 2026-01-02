# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/kbd.inc"
.section .text
.code16
.global kbd_proc

# kbd_proc()
# <req> al = kc
kbd_proc:
	# {
	# (kc == bs) ? {key.bs}
	cmp $CHR_BS, %al
	je .call__key_bs
	# (kc == cr) ? {key.cr}
	cmp $CHR_CR, %al
	je .call__key_cr

	# (kc == tab) ? {key.tab}
	cmp $KBD_KC_TAB, %al
	je .done
	# (kc == esc) ? {key.esc}
	cmp $KBD_KC_ESC, %al
	je .done
	# }

	# TODO: check (kc >= 0x80)
	# { arrow
	# (kc == up) ? {key.up}
	cmp $KBD_KC_UP, %al
	je .call__key_up
	# (kc == down) ? {key.down}
	cmp $KBD_KC_DOWN, %al
	je .call__key_down
	# (kc == left) ? {key.left}
	cmp $KBD_KC_LEFT, %al
	je .call__key_left
	# (kc == right) ? {key.right}
	cmp $KBD_KC_RIGHT, %al
	je .call__key_right
	# }

	# { numpad
	# (kc == num_sl) ? {key.n.sl}
	cmp $KBD_KC_NUM_SL, %al
	je .key__num_sl
	# (kc == num_ent) ? {key.n.cr}
	cmp $KBD_KC_NUM_ENT, %al
	je .call__key_cr
	# }

	# { fn
	# (kc == f1) ? {key.f1}
	cmp $KBD_KC_F1, %al
	je .done
	# (kc == f2) ? {key.f2}
	cmp $KBD_KC_F2, %al
	je .done
	# }
	jmp .norm

.key__num_sl:
	mov $CHR_SL, %al
	jmp .norm

.norm:
	# { pre-update
	# update cl_sbuf
	push %ax # [s.0:kc]
	inc %si # cl_sbuf.data
	mov (cl_sbuf), %ax # cl.size
	inc %ax
	mov %ax, (cl_sbuf)

	# update curs max
	mov (curs+0x02), %ax # curs.max
	inc %ax
	mov %ax, (curs+0x02)
	pop %ax # [s.0:kc]
	# }

	# (*(cl.data-1) != null) ? {shr.cl}
	mov -0x01(%si), %ah
	test %ah, %ah
	jnz .call__shr_cl

	# {
	push %ax # [s.f0:kc]
	call vga_putc
	pop %ax # [s.f0:kc]

	# store chr
	mov %al, -0x01(%si) # cl.data
	# }

.done:
	ret

.call__shr_cl:
	xor %ah, %ah
	push %ax
	push %si
	call disp_shr_cl
	add $0x04, %sp
	jmp .done

.call__key_cr:
	call kbd_hdl_cr
	jmp .done

.call__key_bs:
	call kbd_hdl_bs
	jmp .done

.call__key_up:
	call kbd_hdl_up
	jmp .done

.call__key_down:
	call kbd_hdl_down
	jmp .done

.call__key_left:
	call kbd_hdl_left
	jmp .done

.call__key_right:
	call kbd_hdl_right
	jmp .done
