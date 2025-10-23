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

	push (root_inum) # (inum_lo)
	push (root_inum+0x02) # (inum_hi)
	mov $indp+INDP_OFF_CUR, %si
	push %si # (*indp)
	call ind_read4
	add $0x06, %sp

	call ind_add
	# <dx:ax = inum_hi:inum_lo>
	mov %ax, (tmp_inum)
	mov %dx, (tmp_inum+0x02)

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	mov $indp+INDP_OFF_TMP, %si
	push %si # (*indp)
	call ind_read4
	add $0x06, %sp

	#mov 0x04(%bp), %si
	#push %si
	#xor %ax, %ax
	#push %ax
	#call strlen
	#add $0x04, %sp
	# <ax = str_size>
	#mov $0x80, %ah

	#push %si # (&name)
	#push %ax # (info)
	#push (root_inum) # (src_inum_lo)
	#push (root_inum+0x02) # (src_inum_hi)
	#push (tmp_inum) # (dest_inum_lo)
	#push (tmp_inum+0x02) # (dest_inum_hi)
	#call dent_add
	#add $0x0C, %sp
	# TODO:
	# dent_add2(&name_str, f_type)
	# chk f_type if dir {dir}
	push 0x06(%bp) # (f_type)
	push 0x04(%bp) # (&name_str)
	call dent_add2
	add $0x04, %sp
	# <ax = rec_size>

	push %ax # [s.f0:rec_size]
	push (root_inum)
	push (root_inum+0x02)
	mov $indp+INDP_OFF_CUR, %si
	# TODO: indp set
	#push INDP_OFF_INUM(%si)
	#push INDP_OFF_INUM+0x02(%si)
	push %si
	call ind_read4
	add $0x06, %sp
	pop %ax # [s.f0:rec_size]

	mov $indp+INDP_OFF_CUR, %si
	mov IND_OFF_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, IND_OFF_FILE_SIZE(%si)
	push %si # (*indp)
	call ind_write
	add $0x02, %sp

	pop %si
	pop %bp
	ret
