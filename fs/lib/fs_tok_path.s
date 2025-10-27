# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Tokenize path

.include "chr.s"
.section .text
.code16
.global fs_tok_path

# fs_tok_path(ub8 *path_str)
# <mod> path_sbuf
# <ret> ax = true:0
fs_tok_path:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	push $path_sbuf
	call bufzero
	add $0x02, %sp

	# {init.lp}
	mov 0x04(%bp), %si
	mov $path_sbuf, %di
	add $0x02, %di # skip len
	xor %cx, %cx # buf len

	# (*path[0] != slash) ? {lp}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .lp

	# TODO: relative path
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
	xor %ax, %ax
	jmp .epil

.epil:
	pop %di
	pop %si
	pop %bp
	ret
