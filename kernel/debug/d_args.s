# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug for argument-vector and argument-count

.section .text
.code16
.global d_args

# d_args()
d_args:
	push %si
	push %di
	push %bx

	# {init} raw_buf
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si

	# {main} show argc
	mov $argc, %di
	mov (%di), %cx
	mov %cx, %ax
	add $0x30, %al
	push %cx
	call sys_tty_out
	pop %cx

	# {init} argv
	mov $argv, %di

.show_argv:
	# {end}
	test %cx, %cx
	jz .done
	call outnl

	# {update}
	mov $raw_buf, %si
	add $0x02, %si
	mov (%di), %ax
	add %ax, %si

	push %si
	call puts
	add $0x02, %sp

	# {step}
	add $0x02, %di
	sub $0x01, %cx
	jmp .show_argv

.done:
	pop %bx
	pop %di
	pop %si
	ret
