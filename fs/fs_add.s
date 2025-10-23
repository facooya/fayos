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

# fs_add(ub8 *name_str)
fs_add:
	push %bp
	mov %sp, %bp
	push %si

	call ind_add
	# <dx:ax = inum_hi:inum_lo>
	mov %ax, (tmp_inum)
	mov %dx, (tmp_inum+0x02)

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	call ind_read3
	add $0x04, %sp
	# <dx:ax = ind_seg:ind_off>

	mov 0x04(%bp), %si
	push %si
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp
	# <ax = str_size>
	mov $0x80, %ah

	push %si # (&name)
	push %ax # (info)
	push (root_inum) # (src_inum_lo)
	push (root_inum+0x02) # (src_inum_hi)
	push (tmp_inum) # (dest_inum_lo)
	push (tmp_inum+0x02) # (dest_inum_hi)
	call dent_add
	add $0x0C, %sp
	# <ax = rec_size>

	# TODO: ind_upd

	pop %si
	pop %bp
	ret
