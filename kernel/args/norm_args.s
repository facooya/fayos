# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Normalize for arguments

.include "chr.s"
.section .text
.code16
.global norm_args

# norm_args()
# si,bx = (raw_buf) len, data
# di,cx = (tmp_buf) len, data
norm_args:
	push %si
	push %di
	push %bx

	# {init}
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	# {init}
	mov $tmp_buf, %di
	add $0x02, %di
	xor %cx, %cx

	# {exit}
	test %bx, %bx
	jz .exit

.cpy:
	test %bx, %bx
	jz .cpy_buf
	mov (%si), %al

	cmp $CHR_HYPHEN, %al
	je .norm_opt

	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .chk_opt

.norm_opt:

.exit:

.done:
	pop %bx
	pop %di
	pop %si
	ret
