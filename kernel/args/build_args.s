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

	# {init} argc
	# mov $argc, %di
	# xor %dx, %dx
	# mov %dx, (%di)

	# {init} argc
	mov $args, %di
	xor %dx, %dx
	mov %dx, (%di)
	add $0x02, %di

	# {init} argv_0
	mov %dx, (%di)
	add $0x02, %di

	# {init} argv
	# mov $argv, %di
	# mov %dx, (%di)
	# add $0x02, %di

	# {init}
	xor %cx, %cx
	add $0x01, %cx

	jmp .build

# <PRE>
# *si != null
# <RET>
# dx += idx
.build:
	mov (%si), %al

	# (chr == 0)
	test %al, %al
	jz .build__next

	add $0x01, %si # buf_idx
	sub $0x01, %bx # len
	add $0x01, %dx # idx
	jmp .build

# <PRE>
# *si == null
.build__next:
	add $0x01, %si # buf_idx
	sub $0x01, %bx # len

	# (len == 0)
	test %bx, %bx
	jz .done

	add $0x01, %dx # idx
	add $0x01, %cx # argc
	mov %dx, (%di) # argv
	add $0x02, %di
	jmp .build

.done:
	# set argc
	# mov $argc, %si
	# mov %cx, (%si)

	# set argc
	mov $args, %di
	mov %cx, (%di)

	# set argv_1
	# mov $argv, %si
	# add $0x02, %si
	# mov (%si), %ax
	# mov %ax, (argv_1)

	pop %bx
	pop %di
	pop %si
	ret
