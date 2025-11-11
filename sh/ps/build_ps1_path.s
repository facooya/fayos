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

	call dbg_path_cv

	mov $path_cv, %bx
	mov (%bx), %cx
	add $0x02, %bx

	# {{{ clear
	mov $ps1_path, %di
	push %cx # [s.0:pathc]
	xor %ax, %ax
	push %di # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp

	push %ax # (size)
	xor %ax, %ax
	push %ax # (value
	push %di # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp
	pop %cx # [s.0:pathc]
	# }}}

	jmp .lp2

.lp2:
	mov (%bx), %ax
	mov $path_sbuf, %si
	add $0x02, %si
	mov %ax, %si

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
	jmp .lp2

.add:
	push %cx # [s.f1:pathc]
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp

	push %ax # [s.f0:size]
	push %ax # (size)
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call add_ps1_path
	add $0x06, %sp
	pop %ax # [s.f0:size]
	pop %cx # [s.f1:pathc]

	add $0x02, %bx
	jmp .end__chk

.sub:
	push %cx # [s.f1:pathc]
	call sub_ps1_path
	pop %cx # [s.f1:pathc]

	add $0x02, %bx
	jmp .end__chk

	# (pathc == 1) ? {root} : {lp}
	cmp $0x01, %cx
	je .single

	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di
	jmp .lp

.single:
	mov (%si), %ax
	cmp $0x002F, %ax
	je .single__root

	cmp $0x002E, %ax
	je .single__dot

	cmp $0x2E2E, %ax
	je .single__dots_chk

	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di
	jmp .lp

.single__dots_chk:
	mov 0x02(%si), %al
	test %al, %al
	jz .single__dots
	jmp .lp

.single__root:
	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	jmp .done

.single__dot:
	# (pathc == 0) ? {end} : {lp}
	sub $0x01, %cx
	test %cx, %cx
	jz .end
	add $0x02, %si
	jmp .lp

.single__dots:
	call sub_ps1_path
	# (pathc == 0) ? {end}
	sub $0x01, %cx
	test %cx, %cx
	jz .end
	jmp .lp

.lp:
	# (path_buf[i] == slash) ? {chk}
	mov (%si), %al
	cmp $CHR_SL, %al
	je .chk__sl

	# (path_buf[i] == null) ? {chk}
	test %al, %al
	jz .chk__zero

	mov %al, (%di)
	add $0x01, %di

	# {lp}
	add $0x01, %si
	jmp .lp

.chk__sl:
	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	# (pathc == 0) ? {end}
	sub $0x01, %cx
	test %cx, %cx
	jz .end

	# {lp}
	add $0x02, %si
	jmp .lp

.chk__zero:
	# (pathc == 0) ? {end}
	sub $0x01, %cx
	test %cx, %cx
	jz .end

	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	# {lp}
	add $0x01, %si
	jmp .lp

.end:
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret
