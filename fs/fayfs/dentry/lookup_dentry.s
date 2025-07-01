# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Lookup directory entry

.section .text
.code16
.global lookup_dentry

# lookup_dentry(
# i_num_hi, i_num_lo
# len,
# name
# )
lookup_dentry:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
