# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Build path count, vector

.section .text
.code16
.global fs_build_path

# fs_build_path()
# <req> path_sbuf
# <mod> path_cv
fs_build_path:
	push %si
	push %di
	push %bx

	mov $path_sbuf, %si
	mov (%si), %bx
	add $0x02, %si # skip bufs

	mov $path_cv, %di
	add $0x02, %di # skip pathc
	mov %ax, %ax
	mov %ax, (%di)
	add $0x02, %di # skip pathv[0]
	xor %cx, %cx # pathc
	add $0x01, %cx
	xor %dx, %dx # pathv

.lp:
	# (*buf[i] == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz .chk

	# {lp}
	add $0x01, %si
	add $0x01, %dx # pathv
	jmp .lp

.chk:
	# store pathv
	add $0x01, %dx # skip null
	mov %dx, (%di)
	add $0x02, %di # pathv[i]
	add $0x01, %cx # pathc
	add $0x01, %si

	# (*buf[i] == null) ? {end} : {lp}
	mov (%si), %al
	test %al, %al
	jz .end
	jmp .lp

.end:
	sub $0x01, %cx
	mov %cx, (path_cv)
	jmp .done

.done:
	xor %ax, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	ret
