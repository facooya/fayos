# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Path] Read path

.include "chr.s"
.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.include "fs/de.s"
.section .text
.code16
.global path_read

# path_read()
# <req> fsp *root, path_cv, path_sbuf
# <mod> (fsp *dir, *base)
# <ret> ax = {done:0, exit:1, neq_last:2}
path_read:
	push %es
	push %si
	push %di
	push %bx

	mov $path_cv, %si
	mov (%si), %cx # pathc
	add $0x02, %si # skip pathc

	# (pathc == 1) ? {single}
	cmp $0x01, %cx
	je .single

	mov $path_sbuf, %di
	add $0x02, %di
	mov (%si), %ax
	add %ax, %di

	mov (%di), %al # pathv[0]
	cmp $CHR_SL, %al
	je .abs
	jmp .cur

.single:
	# (pathv[0] == slash) ? {root} : {cur}
	mov (%si), %al
	cmp $CHR_SL, %al
	je .single__root
	mov $fsp+FSP_OFF_CUR, %di
	jmp .single__run

.single__root:
	mov $fsp+FSP_OFF_ROOT, %di

.single__run:
	mov FSP_OFF_INUM(%di), %ax
	mov FSP_OFF_INUM+0x02(%di), %dx

	push %cx # [s.f2:pathc]
	push %ax # [s.f0:inum_lo]
	push %dx # [s.f1:inum_hi]
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_DIR # (fsp &dst)
	call fsp_read
	add $0x06, %sp
	pop %dx # [s.f1:inum_hi]
	pop %ax # [s.f0:inum_lo]
	pop %cx # [s.f2:pathc]
	jmp .lp

.abs:
	mov $(FS_ROOT_INUM>>0x10), %dx
	mov $(FS_ROOT_INUM&0xFFFF), %ax

	# skip pathv[0]
	add $0x02, %si
	sub $0x01, %cx
	jmp .lp

.cur:
	mov $fsp+FSP_OFF_CUR, %di
	mov FSP_OFF_INUM(%di), %ax
	mov FSP_OFF_INUM+0x02(%di), %dx
	jmp .lp

.lp:
	# (pathc == 0) ? {done}
	test %cx, %cx
	jz .done

	push %cx # [s.0:pathc]
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_DIR # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	mov $path_sbuf, %di
	add $0x02, %di # skip bufs
	mov (%si), %ax # pathv[i]
	add %ax, %di

	push %di # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = true:off, false:1>
	pop %cx # [s.f0:pathc]

	# (de_seek() == false) ? {err} : off+=ret
	cmp $0x01, %ax
	je .chk__err
	add %ax, %bx
	# }}}

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx

	# {lp}
	add $0x02, %si
	sub $0x01, %cx
	jmp .lp

.chk__err:
	sub $0x01, %cx
	test %cx, %cx
	jz .done__last
	jmp .exit

# {DONE}
.done:
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_BASE # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	xor %ax, %ax
	jmp .epil

.done__last:
	xor %ax, %ax
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_DIR # (&s_off)
	push %ax # (&s_seg)
	push $fsp+FSP_OFF_BASE # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov $0x02, %ax
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret
