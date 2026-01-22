# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/disk.inc"
.include "fs/fs.inc"
.include "fs/ind.inc"
.include "fs/de.inc"
.section .text
.code16
.global path_parse

# path_parse(ub8 *path)
# <req> fsp *root
# <mod> (fsp *dir, *base), path_cv, path_sbuf
# <ret> ax = {done:0, exit:1, neq_last:2}
path_parse:
	push %bp
	mov %sp, %bp

	push 0x04(%bp) # (&path)
	call _path_tok
	add $0x02, %sp
	# <mod: path_sbuf>

	call _path_build
	# <req: path_sbuf>
	# <mod: path_cv>

	call _path_read
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, ne_last:2}>

	pop %bp
	ret

# _path_tok(ub8 *path)
# <mod> path_sbuf
_path_tok:
	push %bp
	mov %sp, %bp
	push %si
	push %di

	# zero
	xor %ax, %ax
	mov (path_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $path_sbuf # (&off)
	push %ds # (&seg)
	call mem_set
	add $0x08, %sp

	# {init.lp}
	mov 0x04(%bp), %si
	mov $path_sbuf, %di
	add $0x02, %di # skip len
	xor %cx, %cx # buf len

	# (*path[0] != slash) ? {lp}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne 1f

	# first slash
	mov $CHR_SL, %al
	mov %al, (%di)
	xor %al, %al
	mov %al, 0x01(%di)
	add $0x02, %di
	add $0x02, %cx
	add $0x01, %si

	# (*path[1] == null) ? {end.pre}
	mov (%si), %al
	test %al, %al
	jz 91f

1:
	# (*path[i] == null) ? {end}
	mov (%si), %al
	test %al, %al
	je 90f

	# (*path[i] == slash) ? {chk}
	cmp $CHR_SL, %al
	je 2f

	# cpy
	mov %al, (%di)

	inc %si
	inc %di
	inc %cx
	jmp 1b

2:
	# store null
	xor %al, %al
	mov %al, (%di)
	inc %di
	inc %cx

	inc %si
	jmp 1b

90:
	# store last null
	xor %al, %al
	mov %al, (%di)
	add $0x01, %di
	add $0x01, %cx

91:
	mov $path_sbuf, %di
	mov %cx, (%di)

	pop %di
	pop %si
	pop %bp
	ret

# _path_build()
# <req> path_sbuf
# <mod> path_cv
_path_build:
	push %si
	push %di
	push %bx

	mov $path_sbuf, %si
	mov (%si), %bx
	add $0x02, %si # skip bufs

	mov $path_cv, %di
	add $0x02, %di # skip pathc
	mov %ax, %ax
	mov %ax, (%di)
	add $0x02, %di # skip pathv[0]
	xor %cx, %cx # pathc
	add $0x01, %cx
	xor %dx, %dx # pathv

10:
	# (*buf[i] == null) ? {chk}
	mov (%si), %al
	test %al, %al
	jz 11f

	inc %si
	inc %dx # pathv
	jmp 10b

11:
	# store pathv
	inc %dx # skip null
	mov %dx, (%di)
	add $0x02, %di # pathv[i]
	inc %cx # pathc
	inc %si

	# (*buf[i] == null) ? {end} : {lp}
	mov (%si), %al
	test %al, %al
	jz 19f
	jmp 10b

19:
	dec %cx
	mov %cx, (path_cv)
	jmp 90f

90:
	xor %ax, %ax
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	ret

# _path_read()
# <req> fsp *root, path_cv, path_sbuf
# <mod> (fsp *dir, *base)
# <ret> ax = {done:0, exit:1, neq_last:2}
_path_read:
	push %es
	push %si
	push %di
	push %bx

	mov $path_cv, %si
	mov (%si), %cx # pathc
	add $0x02, %si # skip pathc

	# (pathc == 1) ? {single}
	cmp $0x01, %cx
	je 1f # chk root

	mov $path_sbuf, %di
	add $0x02, %di
	mov (%si), %ax
	add %ax, %di

	mov (%di), %al # pathv[0]
	cmp $CHR_SL, %al
	je 10f # absolute
	jmp 11f # current

1: # chk root
	# (pathv[0] == slash) ? {root} : {cur}
	mov $path_sbuf, %di
	add $0x02, %di
	mov (%di), %al
	cmp $CHR_SL, %al
	je 2f
	mov $fsp+FSP_OFF_CUR, %di
	jmp 3f

2: # root
	mov $fsp+FSP_OFF_ROOT, %di
	dec %cx

3: # run
	mov FSP_OFF_INUM(%di), %ax

	push %cx # [s.f2:pathc]
	push %ax # [s.f0:inum]
	push %ax # (inum)
	push $fsp+FSP_OFF_DIR # (fsp &dst)
	call fsp_read
	add $0x04, %sp
	pop %ax # [s.f0:inum]
	pop %cx # [s.f2:pathc]
	jmp 20f

10:
	mov $FS_ROOT_INUM, %ax

	# skip pathv[0]
	add $0x02, %si
	dec %cx
	jmp 20f

11:
	mov $fsp+FSP_OFF_CUR, %di
	mov FSP_OFF_INUM(%di), %ax
	jmp 20f

20:
	# (pathc == 0) ? {done}
	test %cx, %cx
	jz 90f

	push %cx # [s.0:pathc]
	push %ax # (inum)
	push $fsp+FSP_OFF_DIR # (fsp &dst)
	call fsp_read
	add $0x04, %sp

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
	je 21f
	add %ax, %bx
	# }}}

	mov %es:DE_OFF_INUM(%bx), %ax

	add $0x02, %si
	dec %cx
	jmp 20b

21:
	sub $0x01, %cx
	test %cx, %cx
	jz 91f
	jmp 80f

90:
	push %ax # (inum)
	push $fsp+FSP_OFF_BASE # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	xor %ax, %ax
	jmp 99f

91:
	xor %ax, %ax
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_DIR # (&s_off)
	push %ds # (&s_seg)
	push $fsp+FSP_OFF_BASE # (&d_off)
	push %ds # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov $0x02, %ax
	jmp 99f

80:
	mov $0x01, %ax
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# [data]
.section .data
.global path_sbuf
.global path_cv
path_sbuf: .zero 0x100
path_cv: .zero 0x50
