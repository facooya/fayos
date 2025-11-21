# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Process path

.include "fs/fs.s"
.section .text
.code16
.global fs_path

# fs_path(ub8 *path)
# <req> fsp *root
# <mod> (fsp *dir, *base), path_cv, path_sbuf
# <ret> ax = {done:0, exit:1, neq_last:2}
fs_path:
	push %bp
	mov %sp, %bp

	push 0x04(%bp) # (&path)
	call path_tok
	add $0x02, %sp
	# <mod: path_sbuf>

	call path_build
	# <req: path_sbuf>
	# <mod: path_cv>

	call path_read
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, ne_last:2}>

	pop %bp
	ret
