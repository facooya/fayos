# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Initialize curs

.section .text
.code16
.global vga_init_curs

# vga_init_curs()
vga_init_curs:
	call vga_get_curs
	mov %ax, (curs)
	mov %ax, (curs+0x02)
	ret
