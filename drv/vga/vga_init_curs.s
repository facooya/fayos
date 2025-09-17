# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Initialize cursor

.section .text
.code16
.global vga_init_curs

# vga_init_curs()
vga_init_curs:
	call vga_get_curs
	mov %ax, (cursor)
	mov %ax, (cursor+0x02)
	ret
