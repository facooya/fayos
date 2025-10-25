# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Add dot and dots

# TODO: optimize
.include "drv/disk.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.include "fs/ind.s"
.section .data
.dots_str: .asciz ".."
.dot_str: .asciz "."

.section .text
.code16
.global dent_add_dots

# dent_add_dots()
# <req> *indp (tmp)
dent_add_dots:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov $indp+INDP_OFF_TMP, %si
	push IND_OFF_BLK_0(%si) # (blk_lo)
	push IND_OFF_BLK_0+0x02(%si) # (blk_hi)
	call fs_blk_to_lba
	add $0x04, %sp
	# <dx:ax = lba_hi:lba_lo>

	mov $dp+DP_OFF_TMP, %si
	mov %dx, DP_OFF_LBA+0x02(%si)
	mov %ax, DP_OFF_LBA(%si)

	push %si # (*dp)
	call disk_read_dp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	# {{{ dots
	# write inum
	mov $indp+INDP_OFF_CUR, %si
	mov INDP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov INDP_OFF_INUM+0x02(%si), %ax
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	# write info
	mov $0x40, %ax
	mov %al, %es:DE_FILE_TYPE_OFF(%bx)
	mov $0x02, %ax
	mov %al, %es:DE_NAME_LEN_OFF(%bx)

	# write rec_size
	mov $0x02, %cx
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_REC_LEN_OFF(%bx)
	push %cx # [s.0:rec_size]

	# write name
	mov $0x2E2E, %ax
	mov %ax, %es:DE_NAME_OFF(%bx)

	mov $dp+DP_OFF_TMP, %si
	push %si
	call disk_write_dp
	add $0x02, %sp
	# }}}

	pop %ax # [s.0:rec_size]
	mov $indp+INDP_OFF_TMP, %si
	mov %ax, IND_OFF_FILE_SIZE(%si)
	add %ax, %bx

	# {{{ dot
	# write inum
	mov $indp+INDP_OFF_TMP, %si
	mov INDP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov INDP_OFF_INUM+0x02(%si), %ax
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	# write info
	mov $0x40, %ax
	mov %al, %es:DE_FILE_TYPE_OFF(%bx)
	mov $0x01, %ax
	mov %al, %es:DE_NAME_LEN_OFF(%bx)

	# write rec_size
	mov $0x01, %cx
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_REC_LEN_OFF(%bx)
	push %cx # [s.0:rec_size]

	# write name
	mov $0x2E, %al
	mov %al, %es:DE_NAME_OFF(%bx)

	mov $dp+DP_OFF_TMP, %si
	push %si
	call disk_write_dp
	add $0x02, %sp
	# }}}

	pop %ax # [s.0:rec_size]
	mov $indp+INDP_OFF_TMP, %si
	mov IND_OFF_FILE_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, IND_OFF_FILE_SIZE(%si)
	push %si # (*indp)
	call ind_write
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
