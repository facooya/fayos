# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Scan code to keycode

.section .text
.code16
.global kbd_sctokc

# kbd_sctokc()
# <req> ax = scan_code
# <ret> ax = keycode
kbd_sctokc:
	push %si

	# (sc_hi == null) ? {done}
	test %ah, %ah
	jnz .done

	mov $kbd_keymap, %si

	# (sc_hi != shf) ? {shf}
	#cmp $0x12, %ah
	#jne .kc
	#mov $kbd_keymap_shf, %si

.kc:
	add %ax, %si
	mov (%si), %al
	jmp .done

.done:
	pop %si
	ret
