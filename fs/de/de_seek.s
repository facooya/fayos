# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Directory Entry] Seek

.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.include "fs/de.s"
.section .text
.code16
.global de_seek

# de_seek(
# fsp *src
# ub8 *name
# )
# <ret> ax = {true:off, false:1}
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
	push %si # (*off)
	xor %ax, %ax
	push %ax # (*seg)
	call mem_size
	add $0x04, %sp
	mov %ax, %dx # s_name_size
	pop %cx # [s.f0:file_size]

.lp:
	# (file_size <= 0) ? {done.false}
	cmp $0x00, %cx
	jle .done__false

	xor %ax, %ax
	mov %es:DE_OFF_NAME_SIZE(%bx), %al # d_name_size

	# (s_name_size != d_name_size) ? {lp.step}
	cmp %ax, %dx
	jne .lp__step

	# (inum == 0) ? {lp.step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	jz .lp__step

	push %cx # [s.f0:file_size]
	push %dx # [s.f1:s_name_size]
	push %dx # (size)
	push %si # (*s_off)
	xor %ax, %ax
	push %ax # (*s_seg)
	mov %bx, %di
	add $DE_OFF_NAME, %di
	push %di # (*d_off)
	push %es # (*d_seg)
	call mem_cmp
	add $0x0A, %sp
	# <ax = true:0, false:1>
	pop %dx # [s.f1:s_name_size]
	pop %cx # [s.f0:file_size]
	# (mem_cmp() == true) ? {done}
	test %ax, %ax
	jz .done__true

.lp__step:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	sub %ax, %cx # file_size
	jmp .lp

.done__true:
	mov %bx, %ax # <ret.0:off>
	mov 0x04(%bp), %si # (fsp &src)
	mov FSP_OFF_DISK_MEM(%si), %bx
	sub %bx, %ax
	jmp .epil

.done__false:
	mov $0x01, %ax # <ret.1:false>
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
