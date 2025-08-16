# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.include "fayfs/inode.s"
.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %si
	push %di
	push %bx

	call tok_path
	call build_paths
	call dbg_paths

	push $path_buf
	call dbg_buf
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	ret
