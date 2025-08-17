# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Tokenize path and save to path_buf

.include "chr.s"
.section .text
.code16
.global tok_path

# tok_paths(*path)
# <ret> ax = 0:true
tok_path:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	push $path_buf
	call bufzero
	add $0x02, %sp

	# {init.lp}
	mov 0x04(%bp), %si
	mov $path_buf, %di
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
	mov $path_buf, %di
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
