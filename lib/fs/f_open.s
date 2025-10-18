# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Library] File open

.include "fs/fs.s"
.include "fs/ind.s"
.section .text
.code16
.global f_open

# f_open(ub8 *name)
# <ret> f_num
f_open:
	push %bp
	mov %sp, %bp
	push %si
	push %bx

.path_parse:
.path:
	# f_seek
	# if !f_seek() ? {create} || {err}

.f_num:
	xor %cx, %cx
	mov $f_list, %di

.f_num__lp:
	# (fflg == 0) ? {end} : {lp}
	mov (%di), %ax
	test %ax, %ax
	jz .f_num__end

	inc %cx
	add $F_LIST_SIZE, %di
	jmp .f_num__lp

.f_num__end:
	mov %cx, (f_num)

	# TEST
	mov $0x01, %ax
	mov %ax, F_LIST_OFF_FLG(%di)
	xor %ax, %ax
	mov %ax, F_LIST_OFF_IND_LIST_NUM(%di)

	#call mem_alloc
	mov %ax, F_LIST_OFF_MEM(%di)
	mov %dx, F_LIST_OFF_MEM+0x02(%di)

	mov 0x04(%bp), %si
	# call f_seek

.open:

	push $inode
	push $root_inum
	call ind_read
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	mov $dap, %bx
	push $0x08 # sect_cnt
	mov 0x08(%bx), %ax
	push %ax # lba_lo
	mov 0x0A(%bx), %ax
	push %ax # lba_hi
	mov 0x04(%bx), %ax
	push %ax # off
	mov 0x06(%bx), %ax
	push %ax # seg
	call ata_read_sect
	add $0x0A, %sp
	mov %ax, %bx
	mov %dx, %es

	mov $de_hist, %si
	xor %cx, %cx
	mov (%si), %ax
	mov %al, %cl
	add $0x02, %si
	push %si
	push %cx
	mov $inode, %si
	mov IND_OFF_FILE_SIZE(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	mov %es, %dx

	# (dent_seek == no_match) ? {create}
	cmp $0x01, %ax
	je .create
	jmp .done

.create:
	# call f_create
	jmp .done

.done:
	pop %bx
	pop %si
	pop %bp
	ret
