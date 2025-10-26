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
	#push %cx # [s.f0:f_num]
	#push %cx
	#push $root_inum
	#call ind_read2
	#add $0x04, %sp
	#pop %cx # [s.f0:f_num]

	# ((( ind_list += f_num * ind_size
	mov $ind_list, %si
	mov %cx, %ax # f_num
	mov $IND_SIZE, %cx
	mul %cx
	add %ax, %si
	# )))

	call mem_alloc # root

	mov IND_OFF_BLK_0(%si), %cx
	push %cx # blk_num
	push %ax # off
	push %dx # seg
	call disk_read_blk
	add $0x06, %sp
	mov %ax, %bx
	mov %dx, %es

	push %ax
	push %dx
	call mem_free # root
	add $0x04, %sp
	# }}}

	mov 0x04(%bp), %si
	push %si # *name_str
	push %si
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp
	push %ax # name_len
	mov $ind_list, %si
	mov IND_OFF_FILE_SIZE(%si), %ax
	push %ax # file_size
	push %bx # *off
	push %es # *seg
	call lookup_dentry
	add $0x0A, %sp

	# (dent_seek == no_match) ? {create}
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
