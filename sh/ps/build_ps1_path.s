# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build prompt-string-1 path

.include "chr.s"
.include "fs/fs.s"
.section .text
.code16
.global build_ps1_path

# build_ps1_path()
# <req> path_cv, path_sbuf
build_ps1_path:
	push %si
	push %di
	push %bx

	mov $path_cv, %bx
	mov (%bx), %cx # pathc
	add $0x02, %bx
	jmp .lp

.lp:
	mov (%bx), %ax
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si

	mov (%si), %al
	cmp $CHR_PRD, %al
	je .dot__chk
	jmp .add

.dot__chk:
	mov 0x01(%si), %ax
	cmp $0x002E, %ax
	je .sub

	test %al, %al
	jz .end__chk
	jmp .add

.end__chk:
	dec %cx
	test %cx, %cx
	jz .end
	jmp .lp

.add:
	push %cx # [s.f1:pathc]
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp

	push %ax # (size)
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call add_ps1_path
	add $0x06, %sp
	pop %cx # [s.f1:pathc]

	add $0x02, %bx
	jmp .end__chk

.sub:
	push %cx # [s.f1:pathc]
	call sub_ps1_path
	pop %cx # [s.f1:pathc]

	add $0x02, %bx
	jmp .end__chk

.end:
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret
