# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Argument] Build for arg_c, opt_c, arg_v

.section .text
.code16
.global arg_build

# arg_build()
# <info>
# bx:si = (cl_sbuf) size:chr
# di = *arg_ccv
# cx = arg_c
# dx = off
# <mod> cl_sbuf
arg_build:
	push %si
	push %di
	push %bx

	mov $cl_sbuf, %si
	mov (%si), %bx
	add $0x02, %si

	mov $arg_ccv, %di
	add $0x06, %di # skip arg_c+opt_c+arg_v[0]

	xor %cx, %cx # arg_c
	xor %dx, %dx # off
	inc %cx # add arg_v[0]

.lp:
	# (chr == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz .chk

	inc %si # chr
	dec %bx # size
	inc %dx # off
	jmp .lp

.chk:
	inc %si # chr
	dec %bx # size
	inc %dx # off

	# (size == 0) ? {end}
	test %bx, %bx
	jz .end

	# store
	mov %dx, (%di) # off
	add $0x02, %di # step arg_v

	inc %cx # arg_c
	jmp .lp

.end:
	# set arg_c
	mov $arg_ccv, %di
	mov %cx, (%di) # arg_c
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	ret
