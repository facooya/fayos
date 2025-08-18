# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Path

.section .data
.global paths
paths: .zero 0x100

.section .text
.code16
.global proc_paths

# proc_paths(*path_str)
proc_paths:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si

	push %si
	call tok_paths
	add $0x02, %sp

	call build_paths

	# <ret> ax, dx
	call read_paths

	pop %si
	pop %bp
	ret
