# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Argments main
#
# NOTE
# [n_args]
# argc [2-byte]
# optc [2-byte]
# argv [2-byte]-[156-byte]

.section .data
.global args

args: .zero 0x100

.section .text
.code16
.global proc_args

# proc_args()
# <RET>
# ax = 0:true, 1:exit
proc_args:
	push %si

	call ._zero

	# {{{ proc
	call tok_args
	test %ax, %ax
	jnz .exit

	call build_args

	call parse_args
	test %ax, %ax
	jnz .exit

	xor %ax, %ax
	jmp .done
	# }}}

.exit:
	# {zero}
	push $raw_buf
	call clear_buf
	add $0x02, %sp
	call ._zero

	mov $0x01, %ax
	jmp .done

.done:
	pop %si
	ret

._zero:
	push $tmp_buf
	call clear_buf
	add $0x02, %sp

	call clear_redir_buf

	xor %ax, %ax
	mov $args, %si
	mov %ax, (%si) # argc
	mov %ax, 0x02(%si) # optc
	mov %ax, 0x04(%si) # argv[0]
	ret
