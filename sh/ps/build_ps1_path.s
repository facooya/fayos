# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build prompt-string-1 path

.include "chr.s"
.section .text
.code16
.global build_ps1_path

# build_ps1_path()
build_ps1_path:
	push %si
	push %di
	push %bx

	mov $paths, %bx
	mov (%bx), %cx
	add $0x02, %bx

	# {{{ clear
	push %cx # [s.0:pathc]
	mov $ps1_path, %di
	push %di
	xor %ax, %ax
	push %ax
	call mem_size
	add $0x04, %sp

	push %ax
	xor %ax, %ax
	push %ax
	push %di
	push %ax
	call mem_set
	add $0x08, %sp
	pop %cx # [s.0:pathc]
	# }}}

	mov $path_buf, %si
	add $0x02, %si

	# (pathc == 1) ? {root} : {lp}
	cmp $0x01, %cx
	je .root
	jmp .lp

.root:
	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	jmp .done

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
