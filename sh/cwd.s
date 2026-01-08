# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.section .text
.code16
.global cwd_build
.global cwd_init

# cwd_build()
# <req: path_cv, path_sbuf>
# <mod: cwd>
cwd_build:
	push %si
	push %di
	push %bx

	mov $path_cv, %bx
	mov (%bx), %cx # path_c
	add $0x02, %bx

	# (path_c != 1) ? {norm}
	cmp $0x01, %cx
	jne 1f

	mov $path_sbuf, %si
	add $0x02, %si
	mov (%si), %al

	# (data != slash) ? {norm}
	cmp $CHR_SL, %al
	jne 1f

	# slash only
	mov $cwd, %di
	mov $CHR_SL, %al
	mov %al, (%di)
	xor %al, %al
	mov %al, 0x01(%di)
	jmp 90f

1: # norm
	mov (%bx), %ax # path_v
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si

	# (*path_buf[path_v] != dot) ? {add}
	mov (%si), %al
	cmp $CHR_PRD, %al
	jne 3f

	# (*path_buf[path_v+1] != dot) ? {chk.s_dot}
	mov 0x01(%si), %al
	cmp $CHR_PRD, %al
	jne 5f
	# (*path_buf[path_v+2] == null) ? {sub} : {add}
	mov 0x02(%si), %al
	test %al, %al
	jz 4f # d_dot
	jnz 3f # file_name

5: # chk s_dot
	# (path_buf[path_v+1] != null) ? {add} : {s_dot}
	test %al, %al
	jnz 3f
	add $0x02, %bx

2: # chk end
	dec %cx
	test %cx, %cx
	jz 90f
	jmp 1b

3: # add
	push %cx # [s.f1:path_c]
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp

	push %ax # (size)
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call _cwd_add
	add $0x06, %sp
	pop %cx # [s.f1:path_c]

	add $0x02, %bx
	jmp 2b

4: # sub
	push %cx # [s.f1:path_c]
	call _cwd_sub
	pop %cx # [s.f1:path_c]

	add $0x02, %bx
	jmp 2b

90:
	pop %bx
	pop %di
	pop %si
	ret

# cwd_init()
# <mod: cwd>
cwd_init:
	push %di

	mov $cwd, %di
	mov $CHR_SL, %al
	mov %al, (%di)
	inc %di

	xor %ax, %ax
	mov %al, (%di)
	inc %di

	pop %di
	ret

# _cwd_add(ub16 *seg, ub16 *off, ub16 size)
# <mod: cwd>
_cwd_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	mov 0x04(%bp), %es # (*seg)
	mov 0x06(%bp), %si # (*off)
	mov $cwd, %di

	mov (%si), %al
	cmp $CHR_SL, %al
	je 90f

	xor %ax, %ax
	push %di # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp
	add %ax, %di

	# (*(cwd--) == SL) ? {pass}
	mov -0x01(%di), %al
	cmp $CHR_SL, %al
	je 1f

	mov $CHR_SL, %al
	mov %al, (%di)
	inc %di

1:
	# mem cpy
	mov 0x08(%bp), %cx # (size)
	xor %ax, %ax
	push %cx # (size)
	push %si # (&s_off)
	push %es # (&s_seg)
	push %di # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp

	# store last null
	mov 0x08(%bp), %ax # (size)
	add %ax, %di
	xor %ax, %ax
	mov %al, (%di)
	inc %di

90:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# _cwd_sub()
# <mod: cwd>
_cwd_sub:
	push %si
	push %di

	mov $cwd, %si
	xor %ax, %ax
	push %si # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp
	add %ax, %si
	dec %si

1:
	# (chr == SL) ? {end}
	mov (%si), %al
	cmp $CHR_SL, %al
	jz 1f

	xor %al, %al
	mov %al, (%si)

	dec %si
	jmp 1b

1:
	mov $cwd, %di
	xor %ax, %ax
	push %di # (&off)
	push %ax # (&seg)
	call mem_size
	add $0x04, %sp

	cmp $0x01, %ax
	je 90f

	xor %ax, %ax
	mov %al, (%si)
	inc %si

90:
	pop %di
	pop %si
	ret

# [data]
.section .data
.global cwd
cwd: .zero 0x100
