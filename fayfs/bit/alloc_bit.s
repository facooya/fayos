# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate bit

.section .text
.code16
.global alloc_bit

# alloc_bit(mem)
# <ret> ax = bitnum
alloc_bit:
	push %bp
	mov %sp, %bp
	push %bx

	mov 0x04(%bp), %bx
	jmp .chk_word

# {TASK}
.chk_word:
	xor %dx, %dx

.chk_word__lp:
	# {task} (block_bitmap != full)
	mov (%bx), %ax
	cmp $0xFFFF, %ax
	jne .chk_bit

	# {lp}
	add $0x02, %bx
	add $0x01, %dx
	jmp .chk_word__lp

# {TASK}
.chk_bit:
	xor %cx, %cx

.chk_bit__lp:
	# {end} (bit != 1)
	bt %cx, %ax
	jnc .chk_bit__end

	# {lp}
	add $0x01, %cx
	jmp .chk_bit__lp

.chk_bit__end:
	# calc bitnum
	push %cx
	mov %dx, %ax
	xor %dx, %dx
	mov $0x10, %cx
	mul %cx
	pop %cx
	add %cx, %ax

# {DONE}
.done:
	pop %bx
	pop %bp
	ret
