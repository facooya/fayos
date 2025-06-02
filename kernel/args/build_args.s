# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build for argument-count and argument-vector

.section .text
.code16
.global build_args

# build_args()
# <INFO>
# si:bx = &raw_buf:len
# di:dx = &args:off
# cx = argc
build_args:
	push %si
	push %di
	push %bx

	# {init} raw_buf
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	# {init} args
	mov $args, %di
	xor %dx, %dx
	mov %dx, (%di) # argc = 0
	add $0x02, %di # skip argc
	mov %dx, (%di) # optc = 0
	add $0x02, %di # skip optc
	mov %dx, (%di) # argv[0] (cmd_idx) = 0
	add $0x02, %di # skip argv[0]

	# set argc
	xor %cx, %cx
	add $0x01, %cx # add argv[0]

	# {task}
	jmp .argv

.argv:
# <PRE>
# (*si != null)
.argv__lp:
	mov (%si), %al

	# {chk} (chr == 0)
	test %al, %al
	jz .argv__chk

	# {lp}
	add $0x01, %si # buf_idx
	sub $0x01, %bx # len
	add $0x01, %dx # v_idx
	jmp .argv__lp

# <PRE>
# (*si == null)
# dx += v_idx
.argv__chk:
	# {step}
	add $0x01, %si # buf_idx
	sub $0x01, %bx # len

	# {end} (len == 0)
	test %bx, %bx
	jz .argv__end

	# {lp}
	add $0x01, %dx # v_idx, skip null
	add $0x01, %cx # argc
	mov %dx, (%di) # *argv = v_idx
	add $0x02, %di # step argv
	jmp .argv__lp

.argv__end:
	# set argc
	mov $args, %di
	mov %cx, (%di)

	# {end.done}
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret
