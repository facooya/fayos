# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build for argument-vector and argument-count

.section .text
.code16
.global build_args

# {ENTRY}
# build_args()
# <INFO>
# si:bx = &raw_buf:len
# di:dx = &argv:argv_off
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
	mov $argc, %di
	xor %dx, %dx
	mov %dx, (%di)

	# {init} argv
	mov $argv, %di
	mov %dx, (%di)
	add $0x02, %di

	# {init}
	xor %cx, %cx
	add $0x01, %cx

# {MAIN} BUILD
.build:
	mov (%si), %al

	# (chr == 0)
	test %al, %al
	jz .build_next

	# {loop}
	add $0x01, %si
	sub $0x01, %bx
	add $0x01, %dx
	jmp .build

.build_next:
	# {loop}
	add $0x01, %si
	sub $0x01, %bx

	# (len == 0)
	test %bx, %bx
	jz .build_end

	# argv, argc
	add $0x01, %dx
	mov %dx, (%di)
	add $0x02, %di
	add $0x01, %cx

	# {loop}
	jmp .build

.build_end:
	# update argc
	mov $argc, %si
	mov %cx, (%si)

	# update argv_1
	mov $argv, %si
	add $0x02, %si
	mov (%si), %ax
	mov %ax, (argv_1)

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	ret
