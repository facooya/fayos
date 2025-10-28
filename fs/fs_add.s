# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Add file or directory

.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global fs_add

# fs_add(ub8 *name_str, ub16 f_type)
fs_add:
	push %bp
	mov %sp, %bp
	push %si

	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	push %ax
	push %dx
	mov $fsp+FSP_OFF_TMP, %si
	push %si # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push 0x06(%bp) # (f_type)
	push 0x04(%bp) # (&name_str)
	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add
	add $0x08, %sp
	# <ax = rec_size>

	mov $fsp+FSP_OFF_CUR, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, FSP_OFF_IND_FILE_SIZE(%si)
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	# (f_type != dir) ? {done} : {add_dots}
	mov 0x06(%bp), %ax
	cmp $0x40, %ax
	jne .done

	push $fsp+FSP_OFF_CUR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp

.done:
	pop %si
	pop %bp
	ret
