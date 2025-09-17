# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Clear

.section .text
.code16
.global cmd_clear

# cmd_clear()
cmd_clear:
	call vga_clr
	ret
