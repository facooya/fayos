# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Out string

.section .text
.code16
.global outs

# outs(&str)
outs:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si

.lp:
	# {end.done}
	mov (%si), %al
	test %al, %al
	jz .done

	call outc

	# {lp}
	add $0x01, %si
	jmp .lp

.done:
	pop %si
	pop %bp
	ret
