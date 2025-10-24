# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Add

.include "drv/disk.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.include "fs/ind.s"
.section .text
.code16
.global dent_add2

# dent_add2(
# ub8 *name_str,
# ub16 f_type
# )
# <req> *indp
# <ret> ax = rec_size
dent_add2:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov $indp+INDP_OFF_CUR, %si
	mov IND_OFF_FILE_SIZE(%si), %ax
	push %ax # [s.0:file_size]

	push IND_OFF_BLK_0(%si) # (blk_lo)
	push IND_OFF_BLK_0+0x02(%si) # (blk_hi)
	call fs_blk_to_lba
	add $0x04, %sp
	# <dx:ax = lba_hi:lba_lo>

	mov $dp+DP_OFF_CUR, %si
	mov %dx, DP_OFF_LBA+0x02(%si)
	mov %ax, DP_OFF_LBA(%si)

	push %si # (*dp)
	call disk_read_dp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	pop %ax # [s.0:file_size]
	add %ax, %bx
	jmp .write

.write:
	# write inum
	mov $indp+INDP_OFF_TMP, %si
	mov INDP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov INDP_OFF_INUM+0x02(%si), %ax
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	# write info
	mov 0x06(%bp), %ax
	mov %al, %es:DE_FILE_TYPE_OFF(%bx)
	mov 0x04(%bp), %si
	push %si
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp
	mov %al, %es:DE_NAME_LEN_OFF(%bx)

	# write rec_size
	xor %cx, %cx
	mov %al, %cl
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_REC_LEN_OFF(%bx)
	push %cx

	# dest name
	mov %bx, %di
	add $DE_NAME_OFF, %di

	mov 0x0E(%bp), %si # name
	xor %cx, %cx
	mov %al, %cl # name_size

# TODO: mem_cpy
.write__name_lp:
	# (name_size == 0) ? {end}
	test %cl, %cl
	jz .write__end

	# cpy
	mov (%si), %al
	mov %al, %es:(%di)

	add $0x01, %si
	add $0x01, %di
	sub $0x01, %cl
	jmp .write__name_lp

.write__end:
	mov $dp+DP_OFF_CUR, %si
	push %si
	call disk_write_dp
	add $0x02, %sp

	# {end.done}
	pop %ax # <ret:rec_size>
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
