# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Remove directory or file

.include "fs/fs.s"
.include "fs/de.s"
.section .text
.code16
.global fs_rm

# fs_rm(fsp *src, ub8 *name)
fs_rm:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	push 0x04(%bp) # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push 0x06(%bp) # (&name)
	push 0x04(%bp) # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	je .dir__down
	jmp .done # HACK TODO: file

.dir__down:
	mov $fsp+FSP_OFF_TMP, %si
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push %si # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	add $0x18, %bx
	mov $0x18, %cx

	mov FSP_OFF_F_SIZE(%si), %dx
	sub $0x18, %dx
	cmp $0x00, %dx
	jle .dir__rm
	jmp .dir__find_lp

.dir__find_lp:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .dir__find_step

	# (f_type == dir) ? {chk}
	mov %es:DE_OFF_FILE_TYPE(%bx), %al
	cmp $0x40, %al
	je .dir__find_chk
	jmp .dir__find_step

.dir__find_step:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx # mem
	add %ax, %cx # rec_size

	# (file_size <= 0) ? {end} : {lp}
	sub %ax, %dx # f_size
	cmp $0x00, %dx
	jle .dir__rm
	jmp .dir__find_lp

.dir__find_chk:
	push %dx # [s.f0:f_size]
	push %cx # [s.f1:rec_size]
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM(%bx), %dx
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push $fsp+FSP_OFF_BASE # (fsp &dst) HACK
	call fsp_read
	add $0x06, %sp
	pop %cx # [s.f1:rec_size]
	pop %dx # [s.f0:f_size]

	# (f_size == dots) ? {find_step} : {down_lp}
	mov $fsp+FSP_OFF_BASE, %di # HACK
	mov FSP_OFF_F_SIZE(%di), %ax
	cmp $0x18, %ax
	je .dir__find_step
	jmp .dir__down

.dir__rm:
	mov $fsp+FSP_OFF_TMP, %si
	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# { pre upd
	mov FSP_OFF_F_SIZE(%si), %dx
	mov $0x18, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)

	push %ax # [s.f0:dots_size]
	push %dx # [s.f1:f_size]
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp
	pop %dx # [s.f1:f_size]
	pop %ax # [s.f0:dots_size]
	# }

	mov %ax, %cx # pos = dots
	sub %ax, %dx # f_size - dots
	add %ax, %bx # mem + dots

.dir__rm_lp:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	or %es:DE_OFF_INUM+0x02(%bx), %ax
	jz .dir__rm_step

	push %cx # [s.0:rec_size]
	push %dx # [s.1:f_size]
	push %es:DE_OFF_INUM(%bx) # (inum_lo)
	push %es:DE_OFF_INUM+0x02(%bx) # (inum_hi)
	call ind_clr
	add $0x04, %sp

	# clr inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp
	pop %dx # [s.1:f_size]
	pop %cx # [s.0:rec_size]

.dir__rm_step:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	add %ax, %cx
	sub %ax, %dx

	# (f_size <= 0) ? {end} : {lp}
	cmp $0x00, %dx
	jle .dir__rm_end
	jmp .dir__rm_lp

.dir__rm_end:
	push 0x04(%bp) # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push 0x06(%bp) # (&name)
	push 0x04(%bp) # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (del_inum != sel_inum) ? {dir.down} : {clr}
	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_INUM(%si), %cx
	cmp %ax, %cx
	jne .dir__down
	mov FSP_OFF_INUM+0x02(%si), %cx
	cmp %dx, %cx
	jne .dir__down

	push %ax # (inum_lo)
	push %dx # (inum_hi)
	call ind_clr
	add $0x04, %sp

	# clr inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)
	mov %ax, %es:DE_OFF_INUM+0x02(%bx)

	push 0x04(%bp) # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret
