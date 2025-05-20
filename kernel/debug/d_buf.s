# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug buffer

.section .text
.code16
.global d_buf

# d_buf(buf)
d_buf:
	# prol
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	call outnl

	# init
	mov 0x04(%bp), %si
	mov (%si), %cx
	add $0x02, %si

.d_buf__lp:
	cmp $0x00, %cx
	jle .d_buf__done

	mov (%si), %al

	cmp $0x20, %al
	je .d_buf__sp

	test %al, %al
	jz .d_buf__nul

	call sys_tty_out
	jmp .d_buf__step

.d_buf__sp:
	mov $'.', %al
	call sys_tty_out
	jmp .d_buf__step

.d_buf__nul:
	mov $'0', %al
	call sys_tty_out
	jmp .d_buf__step

.d_buf__step:
	add $0x01, %si
	sub $0x01, %cx
	jmp .d_buf__lp

.d_buf__done:
	# epil
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
