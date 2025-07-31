# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	call alloc_mem
	push %dx
	call dbg_reg
	add $0x02, %sp
	push %ax
	call dbg_reg
	add $0x02, %sp
	ret
