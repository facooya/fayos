# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Add dot and dots

.include "drv/disk.s"
.include "fs/de.s"
.include "fs/ind.s"
.include "fs/fs.s"
.section .text
.code16
.global de_add_dots

# de_add_dots(fsp *dst, fsp *src)
de_add_dots:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si # (fsp *dst)
	push %si
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	# {{{ dot
	# write inum
	mov FSP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov FSP_OFF_INUM+0x02(%si), %ax
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

	mov 0x04(%bp), %si # (fsp *dst)
	push %si
	call disk_write_fsp
	add $0x02, %sp
	# }}}

	pop %ax # [s.0:rec_size]
	mov 0x04(%bp), %si # (fsp *dst)
	mov %ax, FSP_OFF_F_SIZE(%si)
	add %ax, %bx

	# {{{ dots
	# write inum
	mov 0x06(%bp), %si # (fsp *src)
	mov FSP_OFF_INUM(%si), %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov FSP_OFF_INUM+0x02(%si), %ax
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

	mov 0x04(%bp), %si # (fsp *dst)
	push %si
	call disk_write_fsp
	add $0x02, %sp
	# }}}

	pop %ax # [s.0:rec_size]
	mov 0x04(%bp), %si # (fsp *dst)
	mov FSP_OFF_F_SIZE(%si), %cx
	add %ax, %cx
	mov %cx, FSP_OFF_F_SIZE(%si)
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
