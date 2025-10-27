# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Add dot and dots

.include "drv/disk.s"
.include "fs/de.s"
.include "fs/ind.s"
.section .text
.code16
.global de_add_dots

# de_add_dots(indp *dots)
# <req> *indp (tmp)
# <req> *dp (tmp)
de_add_dots:
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

	# {{{ dot
	# write inum
	mov $indp+INDP_OFF_TMP, %si
	mov INDP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov INDP_OFF_INUM+0x02(%si), %ax
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	# write info
	mov $DE_DOT_INFO, %ax
	mov %ah, %es:DE_OFF_FILE_TYPE(%bx)
	mov %al, %es:DE_OFF_NAME_SIZE(%bx)

	# write rec_size
	xor %cx, %cx
	mov %al, %cl
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_OFF_REC_SIZE(%bx)
	push %cx # [s.0:rec_size]

	# write name
	mov $DE_DOT_NAME, %al
	mov %al, %es:DE_OFF_NAME(%bx)

	mov $dp+DP_OFF_TMP, %si
	push %si
	call disk_write_dp
	add $0x02, %sp
	# }}}

	pop %ax # [s.0:rec_size]
	mov $indp+INDP_OFF_TMP, %si
	mov %ax, IND_OFF_FILE_SIZE(%si)
	add %ax, %bx

	# {{{ dots
	# write inum
	mov 0x04(%bp), %si # (indp *dots)
	mov INDP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov INDP_OFF_INUM+0x02(%si), %ax
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	# write info
	mov $DE_DOTS_INFO, %ax
	mov %ah, %es:DE_OFF_FILE_TYPE(%bx)
	mov %al, %es:DE_OFF_NAME_SIZE(%bx)

	# write rec_size
	xor %cx, %cx
	mov %al, %cl
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_OFF_REC_SIZE(%bx)
	push %cx # [s.0:rec_size]

	# write name
	mov $DE_DOTS_NAME, %ax
	mov %ax, %es:DE_OFF_NAME(%bx)

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
