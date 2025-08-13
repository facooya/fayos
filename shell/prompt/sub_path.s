# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove current directory name at path

.include "chr.s"
.section .text
.code16
.global sub_path

# sub_path()
sub_path:
	push %si

	mov $path, %si
	
	push %si
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp
	add %ax, %si

	sub $0x01, %si

.lp:
	# {end} (chr == SL)
	mov (%si), %al
	cmp $CHR_SL, %al
	jz .end

	# {lp}
	sub $0x01, %si
	jmp .lp

.end:
	xor %ax, %ax
	mov %al, (%si)
	add $0x01, %si

	pop %si
	ret
