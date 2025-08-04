# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put string format in write buffer

.include "chr.s"
.section .text
.code16
.global putf

# putf(*seg, *off)
putf:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# {init}
	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %si # str
	mov $write_buf, %di
	mov (%di), %bx # buf.len
	add $0x02, %di # skip len
	add %bx, %di # buf.in

.lp:
	# {end.done} (str == null)
	mov %es:(%si), %al
	test %al, %al
	jz .end

	# {hdl} (str == bsl)
	cmp $CHR_BSL, %al
	je .hdl__bsl

	# store in write_buffer
	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %bx
	jmp .lp

.hdl__bsl:
	mov %es:0x01(%si), %al

	# {end} (chr == null)
	test %al, %al
	jz .end
	
	# (chr == n)
	cmp $CHR_LC_N, %al
	je .hdl__bsl_n

	# (chr == bsl)
	cmp $CHR_BSL, %al
	je .hdl__bsl_bsl

	add $0x01, %si
	jmp .lp

.hdl__bsl_n:
	mov $CHR_CR, %al
	mov %al, (%di)
	mov $CHR_LF, %al
	mov %al, 0x01(%di)

	add $0x02, %di # add CR, LF
	add $0x02, %bx
	add $0x02, %si # skip \n
	jmp .lp

.hdl__bsl_bsl:
	mov %al, (%di)
	add $0x01, %di # add BSL
	add $0x01, %bx
	add $0x02, %si # skip \\
	jmp .lp

.end:
	# store len
	mov $write_buf, %di
	mov %bx, (%di)
	jmp .epil

# {DONE}
.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
