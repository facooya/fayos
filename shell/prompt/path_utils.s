# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Path utilities

.include "chr.s"
.section .text
.code16
.global root_path

# root_path()
root_path:
	push %di

	mov $path, %di
	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %di

	pop %di
	ret
