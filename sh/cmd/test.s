# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si

1:
	mov $0x41, %al
	call vga_outc
	jmp 1b

	pop %si
	ret
