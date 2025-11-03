# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Open

.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global fs_open

# fs_open(ub8 *name_str)
# <ret> fd
fs_open:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %bx

.path_parse:
.path:
	# f_seek
	# if !f_seek() ? {create} || {err}

.fd:
	xor %cx, %cx
	mov $ft, %di

.fd__lp:
	# (fflg == 0) ? {end} : {lp}
	mov (%di), %ax
	test %ax, %ax
	jz .fd__end

	inc %cx
	add $FT_SIZE, %di
	jmp .fd__lp

.fd__end:
	mov %cx, (fd)

	jmp .file_add

	# TEST
	mov $0x01, %ax
	mov %ax, FT_OFF_FLG(%di)

	call mem_alloc
	mov %ax, FT_OFF_MEM(%di)
	mov %dx, FT_OFF_MEM+0x02(%di)

	#mov 0x04(%bp), %si
	# call f_seek

.open:
	# {{{ open /
	# ((( ind_list += f_num * ind_size
	# )))

	call mem_alloc # root

	#call disk_read
	mov %ax, %bx
	mov %dx, %es

	push %ax
	push %dx
	call mem_free # root
	add $0x04, %sp
	# }}}

	#call de_seek

	# (de_seek() == false) ? {create}
	cmp $0x01, %ax
	je .file_add

	jmp .done

.file_add:
	jmp .done

.done:
	pop %bx
	pop %si
	pop %es
	pop %bp
	ret
