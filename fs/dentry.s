# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "drv/disk.inc"
.include "fs/fs.inc"
.include "fs/ind.inc"
.include "fs/de.inc"
.section .text
.code16
.global de_add
.global de_add_dots
.global de_seek

# de_add(
# fsp *dst
# fsp *src
# ub8 *name,
# ub8 f_type
# )
# <rw: fs_write_buf>
de_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si # (fsp *dst)
	mov $fs_write_buf, %di

	mov FSP_OFF_INUM(%si), %ax
	mov %ax, DE_OFF_INUM(%di)

	mov 0x0A(%bp), %ax # (f_type)
	mov %al, DE_OFF_F_TYPE(%di)

	# get name size
	mov 0x08(%bp), %si # (*name)
	push %si
	push %ds
	call mem_size
	add $0x04, %sp
	mov %al, DE_OFF_NAME_SIZE(%di)

	# name -> fs_write_buf
	add $DE_OFF_NAME, %di
	push %ax # [s.f0: name_size]
	push %ax # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	pop %cx # [s.f0: name_size]
	mov $fs_write_buf, %di

	# calc rec size
	add $(DE_SIZE+DE_ALIGN_2), %cx
	and $DE_MASK, %cx
	mov %cx, DE_OFF_REC_SIZE(%di)

	mov 0x06(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %ax

	push %cx # (size)
	push %ax # (idx)
	push %si # (fsp &src)
	call fs_write
	add $0x06, %sp

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# de_add_dots(fsp *dst, fsp *src)
de_add_dots:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# { single dot
	mov 0x04(%bp), %si # (fsp *dst)
	mov $fs_write_buf, %di

	mov FSP_OFF_INUM(%si), %ax
	mov %ax, DE_OFF_INUM(%di)

	mov $DE_S_DOT_INFO, %ax
	mov %ah, DE_OFF_F_TYPE(%di)
	mov %al, DE_OFF_NAME_SIZE(%di)

	mov $DE_S_DOT_NAME, %al
	mov %al, DE_OFF_NAME(%di)

	# calc rec size
	xor %cx, %cx
	mov %al, %cl
	add $(DE_SIZE+DE_ALIGN_2), %cx
	and $DE_MASK, %cx
	mov %cx, DE_OFF_REC_SIZE(%di)

	mov FSP_OFF_F_SIZE(%si), %ax
	push %cx # (size)
	push %ax # (idx)
	push %si # (fsp &src)
	call fs_write
	add $0x06, %sp
	# }

	# { double dot
	mov 0x06(%bp), %si # (fsp *src)
	mov $fs_write_buf, %di

	mov FSP_OFF_INUM(%si), %ax
	mov %ax, DE_OFF_INUM(%di)

	mov $DE_D_DOT_INFO, %ax
	mov %ah, DE_OFF_F_TYPE(%di)
	mov %al, DE_OFF_NAME_SIZE(%di)

	# calc rec size
	xor %cx, %cx
	mov %al, %cl
	add $(DE_SIZE+DE_ALIGN_2), %cx
	and $DE_MASK, %cx
	mov %cx, DE_OFF_REC_SIZE(%di)

	mov $DE_D_DOT_NAME, %ax
	mov %ax, DE_OFF_NAME(%di)

	mov 0x04(%bp), %si # (fsp *dst)
	mov FSP_OFF_F_SIZE(%si), %ax
	push %cx # (size)
	push %ax # (idx)
	push %si # (fsp &src)
	call fs_write
	add $0x06, %sp
	# }

	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# de_seek(
# fsp *src
# ub8 *name
# )
# <ret: ax = {true:off, false:1}>
de_seek:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si # (fsp *src)
	push %si
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	mov 0x04(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %cx # file_size

	push %cx # [s.f0:file_size]
	mov 0x06(%bp), %si # (*name)
	push %si # (off)
	push %ds # (seg)
	call mem_size
	add $0x04, %sp
	mov %ax, %dx # s_name_size
	pop %cx # [s.f0:file_size]

1:
	# (file_size <= 0) ? {done.false}
	cmp $0x00, %cx
	jle 90f

	xor %ax, %ax
	mov %es:DE_OFF_NAME_SIZE(%bx), %al # d_name_size

	# (s_name_size != d_name_size) ? {lp.step}
	cmp %ax, %dx
	jne 2f

	# (inum == 0) ? {lp.step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	jz 2f

	push %cx # [s.f0:file_size]
	push %dx # [s.f1:s_name_size]
	push %dx # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	mov %bx, %di
	add $DE_OFF_NAME, %di
	push %di # (d_off)
	push %es # (d_seg)
	call mem_cmp
	add $0x0A, %sp
	# <ax = true:0, false:1>
	pop %dx # [s.f1:s_name_size]
	pop %cx # [s.f0:file_size]
	# (mem_cmp() == true) ? {done}
	test %ax, %ax
	jz 91f

2:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	sub %ax, %cx # file_size
	jmp 1b

91:
	mov %bx, %ax # <ret.0:off>
	mov 0x04(%bp), %si # (fsp &src)
	mov FSP_OFF_DISK_MEM(%si), %bx
	sub %bx, %ax
	jmp 92f

90:
	mov $0x01, %ax # <ret.1:false>
	jmp 92f

92:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
