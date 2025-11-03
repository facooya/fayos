# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Get bottom directory inum

.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global get_bottom_dir

# get_bottom_dir(*inum)
# <ret> tmp_inum = bottom dir inum
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
	mov 0x02(%si), %dx
	mov %dx, (tmp_inum+0x02)

.down__lp:
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	add $0x18, %bx
	mov $0x18, %cx # rm_rec_size (dots)

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %dx # f_size

	# (file_size <= 0) ? {end}
	sub $0x18, %dx
	cmp $0x00, %dx
	jle .down__end

.find__lp:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .find__lp_step

	# (file_type == dir) ? {chk}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	je .find__chk

.find__lp_step:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx

	add %ax, %cx # rm_rec_size++

	# (file_size <= 0) ? {end} : {lp}
	sub %ax, %dx # file_size--
	cmp $0x00, %dx
	jle .down__end
	jmp .find__lp

.find__chk:
	push %dx # [s.0:f_size]
	push %cx # [s.1:rm_rec_size]

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %ax, (tmp_dir_inum)
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	mov %dx, (tmp_dir_inum+0x02)

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	# (file_size == dots)
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %ax
	cmp $0x18, %ax
	je .find__continue
	jmp .down__continue

.find__continue:
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	pop %cx # [s.1:rm_rec_size]
	pop %dx # [s.0:f_size]

	add %cx, %bx
	jmp .find__lp_step

.down__continue:
	pop %ax # [s.1:rm_rec_size]
	pop %ax # [s.0:f_size]

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
