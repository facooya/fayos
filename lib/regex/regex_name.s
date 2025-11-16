# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Regular Expression] Check name

.include "chr.s"
.section .text
.code16
.global regex_name

# regex_name(*seg, *off)
# <ret> ax = {true:0, false:1}
regex_name:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

	mov 0x04(%bp), %es # (*seg)
	mov 0x06(%bp), %bx # (*off)
	xor %cx, %cx # cnt

.lp:
	# (chr == null) ? {true}
	mov %es:(%bx), %al
	test %al, %al
	jz .true

	# alpha chk
	cmp $CHR_UC_A, %al
	jb .lp__alpha_false
	cmp $CHR_UC_A, %al
	jb .lp__alpha_false
	cmp $CHR_UC_Z, %al
	jbe .lp__step
	cmp $CHR_LC_A, %al
	jb .lp__alpha_false
	cmp $CHR_LC_Z, %al
	jbe .lp__step

.lp__alpha_false:
	# spcial chk
	cmp $CHR_US, %al
	je .lp__step
	cmp $CHR_PRD, %al
	je .lp__step
	cmp $CHR_HY, %al
	je .lp__hy_chk
	jmp .false

.lp__hy_chk:
	# (cnt == 0) ? {false}
	test %cx, %cx
	jz .false
	jmp .lp__step

.lp__step:
	inc %cx
	inc %bx
	jmp .lp

# {DONE}
.true:
	xor %ax, %ax
	jmp .done

.false:
	mov $0x01, %ax
	jmp .done

.done:
	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
