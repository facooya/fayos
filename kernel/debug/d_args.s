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

	# {main} argc
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

	mov (%di), %dx

	# {update}
	mov $raw_buf, %si
	mov (%si), %bx
	add $0x02, %si
	add %dx, %si
	sub %dx, %bx

	# {next}
	call outnl
	add $0x02, %di
	sub $0x01, %cx

.show_argv_chr:
	# {done}
	test %bx, %bx
	jz .done

	mov (%si), %al

	# {next}
	test %al, %al
	jz .show_argv

	call sys_tty_out

	# {step}
	add $0x01, %si
	sub $0x01, %bx
	jmp .show_argv_chr

.done:
	pop %bx
	pop %di
	pop %si
	ret
