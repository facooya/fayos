# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build paths - path count, path vector

.section .text
.code16
.global build_paths

# build_paths()
build_paths:
	push %si
	push %di
	push %bx

	mov $path_buf, %si
	mov (%si), %bx
	add $0x02, %si # skip bufc

	mov $paths, %di
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
	mov %cx, (paths)
	jmp .done

.done:
	xor %ax, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	ret
