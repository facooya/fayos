# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Initial prompt-string-1 path

.include "chr.s"
.section .text
.code16
.global init_ps1

# init_ps1()
init_ps1:
	push %di

	mov $ps1_path, %di
	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %di

	pop %di
	ret
