# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove empty directory base inum

.include "fs/dentry.s"
.include "fs/inode.s"
.section .text
.code16
.global rm_dir

# rm_dir(*inum)
rm_dir:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	push $tmp_inode
	push 0x04(%bp)
	call read_inode
	add $0x04, %sp

	mov $tmp_inode, %si
	mov I_FILE_SIZE_OFF(%si), %dx
	push %dx

	mov $tmp_inode, %si
	mov $0x18, I_FILE_SIZE_OFF(%si)

	push $tmp_inode
	push 0x04(%bp)
	call update_inode
	add $0x04, %sp

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

	pop %dx
	mov $0x18, %cx # rm_rec_len++
	sub $0x18, %dx # file_size--

.clear__lp:
	mov %es:DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or %es:DE_INUM_OFF+0x02(%bx), %ax
	jz .clear__lp_step

	push %cx
	push %dx

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (clear_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (clear_inum+0x02)

	xor %ax, %ax
	mov %ax, %es:DE_INUM_OFF(%bx)
	mov %ax, %es:DE_INUM_OFF+0x02(%bx)

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
	call ata_write_sect
	add $0x0A, %sp

	push $clear_inum
	call clear_inode
	add $0x02, %sp

	pop %dx
	pop %cx

.clear__lp_step:
	mov %es:DE_REC_LEN_OFF(%bx), %ax
	add %ax, %cx # rm_rec_len++
	sub %ax, %dx # file_size--

	# (file_size <= 0)
	cmp $0x00, %dx
	jle .clear__end

	push %cx
	push %dx
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
	pop %dx
	pop %cx

	add %cx, %bx # rm_rec_len
	jmp .clear__lp

.clear__end:

# {DONE}
.done:
	xor %ax, %ax
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret
