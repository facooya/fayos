# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate bit

.section .text
.code16
.global alloc_bit

# alloc_bit(*mem, *bitnum)
# <ret> bnum
alloc_bit:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

	mov 0x04(%bp), %bx # mem
	jmp .chk_word

# {TASK}
.chk_word:
	xor %dx, %dx # word count

.chk_word__lp:
	# {task} (block_bitmap != full)
	mov (%bx), %ax
	cmp $0xFFFF, %ax
	jne .chk_bit

	# {lp}
	add $0x02, %bx
	add $0x01, %dx # word count
	jmp .chk_word__lp

# {TASK}
.chk_bit:
	xor %cx, %cx # bit count

.chk_bit__lp:
	# {end} (bit != 1)
	bt %cx, %ax
	jnc .chk_bit__end

	# {lp}
	add $0x01, %cx # bit count
	jmp .chk_bit__lp

.chk_bit__end:
	# calc bitnum
	push %cx # bit count
	mov %dx, %ax # word count
	xor %dx, %dx
	mov $0x10, %cx
	mul %cx
	pop %cx # bit count
	add %cx, %ax # bitnum

	mov 0x06(%bp), %si # bitnum
	mov %ax, (%si) # bitnum_lo

# {DONE}
.done:
	pop %si
	pop %bx
	pop %bp
	ret
