# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Remove empty directory base inum

.include "fs/fs.s"
.include "fs/de.s"
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

	mov 0x04(%bp), %si
	mov (%si), %ax
	mov 0x02(%si), %dx

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call disk_read_fsp
	add $0x06, %sp

	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %dx
	mov $0x18, %ax
	mov %ax, FSP_OFF_IND_FILE_SIZE(%si)

	push $fsp+FSP_OFF_TMP
	call fsp_write
	add $0x02, %sp

	mov $0x18, %cx # rm_rec_size (dots)
	sub $0x18, %dx # f_size (dots)

.clear__lp:
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .clear__lp_step

	push %cx # [s.0:rm_rec_size]
	push %dx # [s.1:f_size]

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %ax, (clear_inum)
	mov %es:DE_OFF_INUM+0x02(%bx), %ax
	mov %ax, (clear_inum+0x02)

	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	push $fsp+FSP_OFF_TMP
	call disk_write_fsp
	add $0x02, %sp

	push $clear_inum
	call ind_clr
	add $0x02, %sp

	pop %dx # [s.1:f_size]
	pop %cx # [s.0:rm_rec_size]

.clear__lp_step:
	mov %es:DE_REC_LEN_OFF(%bx), %ax
	add %ax, %cx # rm_rec_size++
	sub %ax, %dx # f_size--

	# (file_size <= 0)
	cmp $0x00, %dx
	jle .clear__end

	push %cx # [s.f0:rm_rec_size]
	push %dx # [s.f1:f_size]
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %ax, %bx
	mov %dx, %es
	pop %dx # [s.f1:f_size]
	pop %cx # [s.f0:rm_rec_size]

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
