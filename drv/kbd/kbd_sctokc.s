# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Scan code to keycode

.include "chr.s"
.include "drv/kbd.s"
.section .text
.code16
.global kbd_sctokc

# kbd_sctokc()
# <req> ax = scan_code
# <req> kbd_flg
# <ret> ax = keycode
kbd_sctokc:
	push %si

	# (sc != norm) ? {done}
	test %ah, %ah
	jnz .done

	mov $kbd_keymap, %si
	# (stat == norm) ? {kc}
	mov (kbd_flg), %cx
	test %cx, %cx
	jz .kc

	mov $kbd_keymap_shf, %si
	# ((stat & cap) != 0) ? {cap}
	test $KBD_FLG_CAP, %cx
	jnz .cap
	jmp .kc

.kc:
	add %ax, %si
	mov (%si), %al
	jmp .done

# {CAP}
.cap:
	# ((stat & lshf) != 0) ? {cap.shf}
	test $KBD_FLG_LSHF, %cx
	jnz .cap__shf
	# ((stat & rshf) != 0) ? {cap.shf}
	test $KBD_FLG_RSHF, %cx
	jnz .cap__shf

	# get kc
	mov $kbd_keymap, %si
	add %ax, %si
	mov (%si), %al

	push %ax # [s.0:kc]
	cmp $CHR_LC_A, %al
	jb .cap__re_false
	cmp $CHR_LC_Z, %al
	jbe .cap__re_true
	pop %ax
	jmp .done

.cap__re_true:
	pop %ax # [s.0:kc]
	sub $CHR_CASE_MASK, %al
	jmp .done

.cap__re_false:
	pop %ax # [s.0:kc]
	jmp .done

.cap__shf:
	# get kc
	mov $kbd_keymap_shf, %si
	add %ax, %si
	mov (%si), %al

	push %ax # [s.0:kc]
	cmp $CHR_UC_A, %al
	jb .cap__shf_re_false
	cmp $CHR_UC_Z, %al
	jbe .cap__shf_re_true
	pop %ax
	jmp .done

.cap__shf_re_true:
	pop %ax # [s.0:kc]
	add $CHR_CASE_MASK, %al
	jmp .done

.cap__shf_re_false:
	pop %ax # [s.0:kc]
	jmp .done

.done:
	pop %si
	ret
