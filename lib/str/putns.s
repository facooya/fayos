# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Put string with size in write buffer

.section .text
.code16
.global putns

# putns(*str, n)
putns:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# {init}
	mov 0x04(%bp), %si # *str
	mov 0x06(%bp), %cx # n
	mov $write_buf, %di
	mov (%di), %bx # buf.len
	add $0x02, %di # skip len
	add %bx, %di # buf.in

.lp:
	# {end.done} (count == 0)
	test %cx, %cx
	jz .done

	# copy in write_buffer
	mov (%si), %al
	mov %al, (%di)

	# {lp}
	add $0x01, %si
	add $0x01, %di
	add $0x01, %bx
	sub $0x01, %cx
	jmp .lp
	
.done:
	# store len
	mov $write_buf, %di
	mov %bx, (%di)

	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
