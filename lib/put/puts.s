# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put string in write buffer

.section .text
.code16
.global puts

# puts(*seg, *off)
puts:
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
	jz .done

	# store in write_buffer
	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %bx
	jmp .lp
	
.done:
	# store len
	mov $write_buf, %di
	mov %bx, (%di)

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
