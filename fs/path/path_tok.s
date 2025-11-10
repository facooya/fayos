# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Path] Tokenize path

.include "chr.s"
.section .text
.code16
.global path_tok

# path_tok(ub8 *path)
# <mod> path_sbuf
path_tok:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	# zero
	xor %ax, %ax
	mov (path_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $path_sbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp

	# {init.lp}
	mov 0x04(%bp), %si
	mov $path_sbuf, %di
	add $0x02, %di # skip len
	xor %cx, %cx # buf len

	# (*path[0] != slash) ? {lp}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .lp

	# first slash
	mov $CHR_SL, %al
	mov %al, (%di)
	xor %al, %al
	mov %al, 0x01(%di)
	add $0x02, %di
	add $0x02, %cx
	add $0x01, %si

	# (*path[1] == null) ? {end.pre}
	mov (%si), %al
	test %al, %al
	jz .end__pre

.lp:
	# (*path[i] == null) ? {end}
	mov (%si), %al
	test %al, %al
	je .end

	# (*path[i] == slash) ? {chk}
	cmp $CHR_SL, %al
	je .chk

	# cpy
	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %cx
	jmp .lp

.chk:
	# store null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

	# {lp}
	add $0x01, %si
	jmp .lp

.end:
	# store last null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

.end__pre:
	mov $path_sbuf, %di
	mov %cx, (%di)
	jmp .done

# {DONE}
.done:
	pop %di
	pop %si
	pop %bp
	ret
