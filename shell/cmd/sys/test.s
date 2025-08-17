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

	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	push %si
	call proc_path
	add $0x02, %sp

	call dbg_paths

	push $path_buf
	call dbg_buf
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	ret
