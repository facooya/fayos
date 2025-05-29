# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Build for argument-vector and argument-count

.section .text
.code16
.global build_args

# build_args()
# bx,si = (raw_buf) len, chr
# di,cx = argv, argc
# dx = argv offset
build_args:
	push %si
	push %di
	push %bx

	# {init} raw_buf
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	call clear_args

	# {init} argv
	mov $argv, %di
	xor %dx, %dx
	mov %dx, (%di)
	add $0x02, %di

	# {init} argc
	xor %cx, %cx
	add $0x01, %cx

.build:
	mov (%si), %al

	# {next}
	test %al, %al
	jz .build_next

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	add $0x01, %dx
	jmp .build

.build_next:
	# {step}
	add $0x01, %si
	sub $0x01, %bx

	# {end}
	test %bx, %bx
	jz .build_end

	# {main} argv, argc
	add $0x01, %dx
	mov %dx, (%di)
	add $0x02, %di
	add $0x01, %cx

	# {step}
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

.done:
	pop %bx
	pop %di
	pop %si
	ret
