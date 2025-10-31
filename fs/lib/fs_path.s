# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Process path

.section .text
.code16
.global fs_path

# fs_path(fsp *dst, ub8 *path)
# <req> fsp *root
# <mod> path_cv, path_sbuf
# <ret> ax = {done:0, exit:1, ne_last:2}
fs_path:
	push %bp
	mov %sp, %bp

	push 0x06(%bp) # (&path)
	call fs_tok_path
	add $0x02, %sp
	# <mod: path_sbuf>

	call fs_build_path
	# <req: path_sbuf>
	# <mod: path_cv>

	push 0x04(%bp) # (fsp &dst)
	call fs_read_path
	add $0x02, %sp
	# <ax = {done:0, exit:1, ne_last:2}>

	pop %bp
	ret
