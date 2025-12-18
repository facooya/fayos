# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.s"
.include "drv/kbd.s"
.include "drv/ps2.s"
.section .text
.code16
.global kbd_conv_kc

# kbd_conv_kc()
# <req> scan_code, kbd_mflg
# <ret> al = kc
kbd_conv_kc:
	push %si
	
	mov (scan_code), %ax

	# (sc != norm) ? {done}
	test %ah, %ah
	jnz .ext

	mov $kbd_keymap, %si
	# (mflg == 0) ? {kc}
	mov (kbd_mflg), %cx
	test %cx, %cx
	jz .kc

	# ((mflg & cap) != 0) ? {cap}
	test $KBD_MFLG_CAP, %cx
	jnz .cap

	# ((mflg & lshf) != 0) ? {shf}
	test $KBD_MFLG_LSHF, %cx
	jnz .shf
	# ((mflg & rshf) != 0) ? {shf}
	test $KBD_MFLG_RSHF, %cx
	jnz .shf

	jmp .kc

.shf:
	mov $kbd_keymap_shf, %si
	jmp .kc

.kc:
	add %ax, %si
	mov (%si), %al
	jmp .done

# {CAP}
.cap:
	mov $kbd_keymap_shf, %si

	# ((mflg & lshf) != 0) ? {cap.shf}
	test $KBD_MFLG_LSHF, %cx
	jnz .cap__shf

	# ((mflg & rshf) != 0) ? {cap.shf}
	test $KBD_MFLG_RSHF, %cx
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

# {EXT}
.ext:
	# arrow
	cmp $PS2_SC_UP, %ax
	je .kc__up
	cmp $PS2_SC_DOWN, %ax
	je .kc__down
	cmp $PS2_SC_LEFT, %ax
	je .kc__left
	cmp $PS2_SC_RIGHT, %ax
	je .kc__right

	# num
	cmp $PS2_SC_NUM_SL, %ax
	je .kc__num_sl
	cmp $PS2_SC_NUM_ENT, %ax
	je .kc__num_ent
	jmp .done

# {KC.ARROW}
.kc__up:
	xor %ax, %ax
	mov $KBD_KC_UP, %al
	jmp .done

.kc__down:
	xor %ax, %ax
	mov $KBD_KC_DOWN, %al
	jmp .done

.kc__left:
	xor %ax, %ax
	mov $KBD_KC_LEFT, %al
	jmp .done

.kc__right:
	xor %ax, %ax
	mov $KBD_KC_RIGHT, %al
	jmp .done

# {KC.NUM}
.kc__num_sl:
	xor %ax, %ax
	mov $KBD_KC_NUM_SL, %al
	jmp .done

.kc__num_ent:
	xor %ax, %ax
	mov $KBD_KC_NUM_ENT, %al
	jmp .done

# {DONE}
.done:
	pop %si
	ret
