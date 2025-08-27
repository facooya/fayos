# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get display size

.section .text
.code16
.global get_disp_size

# get_disp_size()
# <ret> dx:ax = row:col
get_disp_size:
	push %bx

	# row
	xor %dx, %dx
	mov $0x0484, %bx
	mov (%bx), %dl

	# col
	mov $0x044A, %bx
	mov (%bx), %ax

	pop %bx
	ret
