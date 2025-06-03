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
# si:bx = (raw_buf) len:&data
# di = &args
# cx = argc
# dx = offset
build_args:
	push %si
	push %di
	push %bx

	# {task}
	jmp .argv

# {TASK}
.argv:
	# {{{ init
	mov $raw_buf, %si
	mov (%si), %bx # len
	add $0x02, %si # skip len

	mov $args, %di
	add $0x06, %di # skip argc+optc+argv[0]

	xor %cx, %cx # argc
	xor %dx, %dx # offset

	add $0x01, %cx # add argv[0]
	# }}}

# <PRE>
# bx:si = (raw_buf) len:&data
# dx = offset
# (*si != null)
.argv__lp:
	# {chk} (raw.data == null)
	mov (%si), %al
	test %al, %al
	jz .argv__chk

	# {lp}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len
	add $0x01, %dx # offset
	jmp .argv__lp

# <PRE>
# (*si == null)
# (dx += offset)
.argv__chk:
	# {step}
	add $0x01, %si # raw.data
	sub $0x01, %bx # raw.len
	add $0x01, %dx # offset, skip null

	# {end} (raw.len == 0)
	test %bx, %bx
	jz .argv__end

	# store
	mov %dx, (%di) # offset
	add $0x02, %di # step argv

	# {lp}
	add $0x01, %cx # argc
	jmp .argv__lp

.argv__end:
	# set argc
	mov $args, %di
	mov %cx, (%di) # argc

	# {end.done}
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	ret
