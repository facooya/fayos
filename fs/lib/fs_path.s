# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Process path

.section .text
.code16
.global fs_path

# fs_path(ub8 *path_str)
fs_path:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si
	push %si
	call fs_tok_path
	add $0x02, %sp
	call fs_build_path
	call fs_read_path

	pop %si
	pop %bp
	ret
