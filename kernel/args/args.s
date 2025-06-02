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
# ax = ret_code
proc_args:
	# TODO: init_all

	call tok_args
	test %ax, %ax
	jnz .exit

	call build_args

	call parse_args
	test %ax, %ax
	jnz .exit

	xor %ax, %ax
	jmp .done

.exit:
	mov $0x01, %ax
	jmp .done

.done:
	ret
