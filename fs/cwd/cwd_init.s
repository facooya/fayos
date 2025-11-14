# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Current Working Directory] Initial path

.include "chr.s"
.section .text
.code16
.global cwd_init

# cwd_init()
cwd_init:
	push %di

	mov $cwd, %di
	mov $CHR_SL, %al
	mov %al, (%di)
	add $0x01, %di

	xor %ax, %ax
	mov %al, (%di)
	add $0x01, %di

	pop %di
	ret
