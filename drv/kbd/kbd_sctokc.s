# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Scan code to keycode

.include "chr.s"
.section .text
.code16
.global kbd_sctokc

# kbd_sctokc()
# <req> ax = scan_code
# <ret> ax = keycode
kbd_sctokc:
	push %si

	# (sc != norm) ? {done}
	test %ah, %ah
	jnz .done

	mov $kbd_keymap, %si
	# (stat == norm) ? {kc}
	mov (kbd_keymap_stat), %cx
	test %cx, %cx
	jz .kc

	mov $kbd_keymap_shf, %si
	# ((stat AND caps) != 0) ? {caps}
	test $(0x01<<0x02), %cx
	jnz .caps
	jmp .kc

.caps:
	# ((stat AND lshf) != 0) ? {caps.shf}
	test $(0x01<<0x00), %cx
	jnz .caps__shf
	# ((stat AND rshf) != 0) ? {caps.shf}
	test $(0x01<<0x01), %cx
	jnz .caps__shf

	# get kc
	mov $kbd_keymap, %si
	add %ax, %si
	mov (%si), %al

	push %ax # [s.0:kc]
	cmp $CHR_LC_A, %al
	jb .caps__re_false
	cmp $CHR_LC_Z, %al
	jbe .caps__re_true
	pop %ax
	jmp .done

.caps__re_true:
	pop %ax # [s.0:kc]
	sub $0x20, %al
	jmp .done

.caps__re_false:
	pop %ax # [s.0:kc]
	jmp .done

.caps__shf:
	# get kc
	mov $kbd_keymap_shf, %si
	add %ax, %si
	mov (%si), %al

	push %ax # [s.0:kc]
	cmp $CHR_UC_A, %al
	jb .caps__shf_re_false
	cmp $CHR_UC_Z, %al
	jbe .caps__shf_re_true
	pop %ax
	jmp .done

.caps__shf_re_true:
	pop %ax # [s.0:kc]
	add $0x20, %al
	jmp .done

.caps__shf_re_false:
	pop %ax # [s.0:kc]
	jmp .done

.kc:
	add %ax, %si
	mov (%si), %al
	jmp .done

.done:
	pop %si
	ret
