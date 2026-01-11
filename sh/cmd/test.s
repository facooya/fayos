# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si

	call _vga_save_top

	pop %si
	ret
