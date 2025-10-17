# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get bottom directory inum

.include "fs/dentry.s"
.include "fs/inode.s"
.section .text
.code16
.global get_bottom_dir

# get_bottom_dir(*inum)
# <ret> tmp_inum bottom dir inum
get_bottom_dir:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %si
	mov (%si), %ax
	mov %ax, (tmp_inum)
	mov 0x02(%si), %ax
	mov %ax, (tmp_inum+0x02)

.down__lp:
	push $tmp_inode
	push $tmp_inum
	call ind_read
	add $0x04, %sp

	mov $tmp_inode, %si
	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

	push $tmp_inode
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

	add $0x18, %bx
	mov $0x18, %cx # rm_rec_len++
	pop %dx # file_size--

	# {end} (file_size <= 0)
	sub $0x18, %dx
	cmp $0x00, %dx
	jle .down__end

.find__lp:
	# {step} (inum == 0)
	mov %es:DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or %es:DE_INUM_OFF+0x02(%bx), %ax
	jz .find__lp_step

	# (file_type == dir)
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	je .find__chk

.find__lp_step:
	mov %es:DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx

	add %ax, %cx # rm_rec_len++

	# {end} (file_size <= 0)
	sub %ax, %dx # file_size--
	cmp $0x00, %dx
	jle .down__end

	# {lp}
	jmp .find__lp

.find__chk:
	push %dx
	push %cx

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (tmp_dir_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (tmp_dir_inum+0x02)

	push $tmp_inode
	push $tmp_dir_inum
	call ind_read
	add $0x04, %sp

	# (file_size == dots)
	mov $tmp_inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	cmp $0x18, %ax
	je .find__continue
	jmp .down__continue

.find__continue:
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

	pop %cx # rm_rec_len++
	pop %dx # file_size--

	add %cx, %bx
	jmp .find__lp_step

.down__continue:
	pop %ax # rm_rec_len++
	pop %ax # file_size--

	mov (tmp_dir_inum), %ax
	mov %ax, (tmp_inum)
	mov (tmp_dir_inum+0x02), %ax
	mov %ax, (tmp_inum+0x02)

	jmp .down__lp

.down__end:
	jmp .done

# {DONE}
.done:
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
