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
.global dent_add

# dent_add(
# ub16 dest_inum_hi,
# ub16 dest_inum_lo,
# ub16 src_inum_hi,
# ub16 src_inum_lo
# ub16 info,
# ub8 *name
# )
# <req> info = file_type:name_size
# <ret> ax = rec_size
dent_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	push 0x0A(%bp) # (inum_lo)
	push 0x08(%bp) # (inum_hi)
	call ind_read3
	add $0x04, %sp
	# <dx:ax = ind_seg:ind_off>
	mov %dx, %es
	mov %ax, %bx
	mov %es:IND_OFF_FILE_SIZE(%bx), %ax
	push %ax # [s.0:file_size]

	push %es:IND_OFF_BLK_0(%bx) # (blk_lo)
	push %es:IND_OFF_BLK_0+0x02(%bx) # (blk_hi)
	call fs_blk_to_lba
	add $0x04, %sp
	# <dx:ax = lba_hi:lba_lo>

	push $DISK_BLK_SECT_CNT # (sect_cnt)
	push %ax # (lba_lo)
	push %dx # (lba_hi)
	call mem_alloc
	# <dx:ax = seg:off>
	push %ax # (off)
	push %dx # (seg)
	call ata_read_sect
	add $0x0A, %sp
	mov %dx, %es
	mov %ax, %bx

	pop %ax # [s.0:file_size]
	add %ax, %bx
	jmp .write

.write:
	# write inum
	mov 0x06(%bp), %ax # dest_inum_lo
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov 0x04(%bp), %ax # dest_inum_hi
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

	# write info
	mov 0x0C(%bp), %dx # dh:dl = file_type:name_size
	mov %dh, %es:DE_FILE_TYPE_OFF(%bx)
	mov %dl, %es:DE_NAME_LEN_OFF(%bx)

	# write rec_size
	xor %cx, %cx
	mov %dl, %cl
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_REC_LEN_OFF(%bx)
	push %cx

	# dest name
	mov %bx, %di
	add $DE_NAME_OFF, %di

	mov 0x0E(%bp), %si # name
	xor %cx, %cx
	mov %dl, %cl # name_size

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
	# TODO disk_cache
	# write blk
	push $DISK_BLK_SECT_CNT # (sect_cnt)
	push $0x80 # (lba_lo)
	xor %ax, %ax
	push %ax # (lba_hi)
	and $0xF000, %bx
	push %bx # (off)
	push %es # (seg)
	call ata_write_sect
	add $0x0A, %sp

	push %bx
	push %es
	call mem_free
	add $0x04, %sp

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
