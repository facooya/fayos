# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Arguments Utils

.section .data
.global arg_ptr

arg_ptr: .word 0x00

.section .text
.code16
.global clear_args
.global set_arg

# ENTRY
# clear_args()
clear_args:
	# prol
	push %si
	push %di

	# init
	mov $argv, %si
	mov $argc, %di
	mov (%di), %cx

.clear_args__zero_lp:
	# cond: cx == 0 ? done
	test %cx, %cx
	jz .clear_args__done

	# zero
	mov (%si), %ax # load (argv)
	xor %ax, %ax
	mov %ax, (%si) # store (argv)

	# loop
	add $0x02, %si
	sub $0x01, %cx
	jmp .clear_args__zero_lp

.clear_args__done:
	mov %cx, (%di) # store (argc)

	# epil
	pop %di
	pop %si
	ret

# ENTRY
# set_arg()
# ret: arg_ptr
set_arg:
	# prol
	push %si

	# get argv
	mov $argv, %si
	add $0x02, %si

	# get offset
	xor %ax, %ax
	mov (%si), %ax

	# calc
	mov $raw_buf, %si
	add %ax, %si

	# set
	mov %si, (arg_ptr)

	# epil
	pop %si
	ret
