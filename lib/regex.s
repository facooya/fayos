# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.section .text
.code16
.global regex_alpha
.global regex_name

# regex_alpha(ub8 *chr)
regex_alpha:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si
	mov (%si), %al

	cmp $CHR_UC_A, %al
	jb 2f
	cmp $CHR_UC_Z, %al
	jbe 1f
	cmp $CHR_LC_A, %al
	jb 2f
	cmp $CHR_LC_Z, %al
	jbe 1f

1: # true
	xor %ax, %ax
	jmp 99f

2: # false
	mov $0x01, %ax

99:
	pop %si
	pop %bp
	ret

# regex_name(*seg, *off)
# <ret: ax = {true:0, false:1}>
regex_name:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %es # (*seg)
	mov 0x06(%bp), %bx # (*off)
	xor %cx, %cx # cnt

1:
	# (chr == null) ? {true}
	mov %es:(%bx), %al
	test %al, %al
	jz 91f

	# alpha chk
	cmp $CHR_UC_A, %al
	jb 2f
	cmp $CHR_UC_A, %al
	jb 2f
	cmp $CHR_UC_Z, %al
	jbe 4f
	cmp $CHR_LC_A, %al
	jb 2f
	cmp $CHR_LC_Z, %al
	jbe 4f

2: # alpha false
	# spcial chk
	cmp $CHR_US, %al
	je 4f
	cmp $CHR_PRD, %al
	je 4f
	cmp $CHR_HY, %al
	je 3f
	jmp 92f

3: # chk hyphen
	# (cnt == 0) ? {false}
	test %cx, %cx
	jz 92f
	jmp 4f

4:
	inc %cx
	inc %bx
	jmp 1b

91: # true
	xor %ax, %ax
	jmp 99f

92: # false
	mov $0x01, %ax
	jmp 99f

99:
	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
