# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove current directory name at path

.include "chr.s"
.section .text
.code16
.global sub_ps1_path

# sub_ps1_path()
sub_ps1_path:
	push %si
	push %di

	mov $ps1_path, %si
	
	push %si
	xor %ax, %ax
	push %ax
	call mem_size
	add $0x04, %sp
	add %ax, %si

	sub $0x01, %si

.lp:
	# {end} (chr == SL)
	mov (%si), %al
	cmp $CHR_SL, %al
	jz .end

	xor %al, %al
	mov %al, (%si)

	# {lp}
	sub $0x01, %si
	jmp .lp

.end:
	mov $ps1_path, %di
	push %di
	xor %ax, %ax
	push %ax
	call mem_size
	add $0x04, %sp

	cmp $0x01, %ax
	je .pass__null

	xor %ax, %ax
	mov %al, (%si)
	add $0x01, %si

.pass__null:
	pop %di
	pop %si
	ret
