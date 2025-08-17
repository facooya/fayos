# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Path

.section .data
.global path
.global paths

path: .zero 0x100
paths: .zero 0x100

.section .text
.code16
.global proc_path

# proc_path(*path)
proc_path:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si

	push %si
	call tok_path
	add $0x02, %sp

	call build_paths

	# <ret> ax, dx
	#call read_path

.epil:
	pop %si
	pop %bp
	ret
