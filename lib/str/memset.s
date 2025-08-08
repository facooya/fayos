# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Memory set

.section .text
.code16
.global memset

# memset(
# *seg
# *off
# value
# num
# )
memset:
	push %bp
	mov %sp, %bp
	push %es
	push %si

	# init
	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %si
	mov 0x08(%bp), %dx
	mov 0x0A(%bp), %cx

.lp:
	# set
	mov %dl, %es:(%si)

	# {end} (num == 0)
	test %cx, %cx
	jz .done

	# {lp}
	add $0x01, %si
	sub $0x01, %cx
	jmp .lp

.done:
	pop %si
	pop %es
	pop %bp
	ret
