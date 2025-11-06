# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Add

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/de.s"
.include "fs/ind.s"
.section .text
.code16
.global de_add

# de_add(
# fsp *dst
# fsp *src
# ub8 *name_str,
# ub16 f_type
# )
# <ret> ax = rec_size
de_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x06(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %ax
	push %ax # [s.0:file_size]

	push %si # (fsp *src)
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	pop %ax # [s.0:file_size]
	add %ax, %bx
	jmp .write

.write:
	# write inum
	mov 0x04(%bp), %si # (fsp *dst)
	mov FSP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov FSP_OFF_INUM+0x02(%si), %ax
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	# write info
	mov 0x0A(%bp), %ax # (f_type)
	mov %al, %es:DE_OFF_FILE_TYPE(%bx)
	mov 0x08(%bp), %si # (*name_str)
	push %si
	xor %ax, %ax
	push %ax
	call mem_size
	add $0x04, %sp
	mov %al, %es:DE_OFF_NAME_SIZE(%bx)

	# write rec_size
	xor %cx, %cx
	mov %al, %cl
	add $0x0B, %cx # fix (8), align 4 (3)
	and $0xFFFC, %cx # mask: 0b1100
	mov %cx, %es:DE_OFF_REC_SIZE(%bx)
	push %cx # [s.0:rec_size]

	# dest name
	mov %bx, %di
	add $DE_OFF_NAME, %di

	mov 0x08(%bp), %si # (*name_str)
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
	mov 0x06(%bp), %si # (fsp *src)
	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp

	# {end.done}
	pop %ax # [s.0:rec_size] <ret.0:rec_size>
	jmp .done

# {DONE}
.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
