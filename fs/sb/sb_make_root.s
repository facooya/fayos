# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Superblock] Make root directory

.include "fs/inode.s"
.include "fs/ind.s"
.section .data
.dent_dot: .asciz "."
.dent_dots: .asciz ".."
.section .text
.code16
.global sb_make_root

# sb_make_root()
sb_make_root:
	push %si

	call disk_init_dp
	call ind_init

	call ind_add
	# <dx:ax = inum_hi:inum_lo>

	push %ax # [s.f0:inum_lo]
	push %dx # [s.f1:inum_hi]
	mov $indp+INDP_OFF_TMP, %si
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push %si # (*indp)
	call ind_read4
	add $0x06, %sp
	pop %dx # [s.f1:inum_hi]
	pop %ax # [s.f0:inum_lo]

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	mov $indp+INDP_OFF_CUR, %si
	push %si # (*indp)
	call ind_read4
	add $0x06, %sp

	mov $0x40, %ax
	push %ax # (f_type)
	push $.dent_dot # (&name_str)
	call dent_add2
	add $0x04, %sp
	# <ax = rec_size>

	mov $indp+INDP_OFF_CUR, %si
	mov IND_OFF_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, IND_OFF_FILE_SIZE(%si)
	push %si # (*indp)
	call ind_write
	add $0x02, %sp

	mov $0x40, %ax
	push %ax # (f_type)
	push $.dent_dots # (&name_str)
	call dent_add2
	add $0x04, %sp
	# <ax = rec_size>

	mov $indp+INDP_OFF_CUR, %si
	mov IND_OFF_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, IND_OFF_FILE_SIZE(%si)
	push %si # (*indp)
	call ind_write
	add $0x02, %sp

	pop %si
	ret
