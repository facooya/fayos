# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Shell history

.include "chr.s"
.include "fs/fs.s"
.include "drv/disk.s"
.include "fs/de.s"
.include "fs/ind.s"

# TODO: history/cache.s
.section .data
.global hist_idx
hist_idx: .word 0x00
.fname_hist: .asciz ".history"

.section .text
.code16
.global history

# history()
# <req> cl_lbuf
history:
	push %es
	push %si
	push %di
	push %bx

	mov $fsp+FSP_OFF_ROOT, %si
	push FSP_OFF_INUM(%si)
	push FSP_OFF_INUM+0x02(%si)
	push $fsp+FSP_OFF_ROOT
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_ROOT
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $.fname_hist # (&name)
	push $fsp+FSP_OFF_ROOT # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}

	# (de_seek == false) ? {create}
	cmp $0x01, %ax
	je .create

	add %ax, %bx
	jmp .save

.create:
	mov $0x80, %ax
	push %ax # (f_type)
	push $.fname_hist # (&name)
	call fs_add
	add $0x04, %sp
	jmp .save

.save:
	mov $fsp+FSP_OFF_ROOT, %si
	push FSP_OFF_INUM(%si)
	push FSP_OFF_INUM+0x02(%si)
	push $fsp+FSP_OFF_ROOT
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_ROOT
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push $.fname_hist # (&name)
	push $fsp+FSP_OFF_ROOT # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	mov %es:DE_OFF_INUM(%bx), %ax
	push %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %ax
	push %ax
	push $fsp+FSP_OFF_TMP
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %ax, %bx

.append:
	mov $cl_lbuf, %si
	mov (%si), %cx # buf.len
	push %cx # [s.4] buf.len
	add $0x02, %si # skip len

.append__lp:
	mov (%si), %al

	# {end} (len == 0)
	test %cx, %cx
	jz .append__end

	mov %al, %es:(%bx)

	# {lp}
	add $0x01, %si # buf.data
	add $0x01, %bx # mem
	sub $0x01, %cx # buf.len
	jmp .append__lp

.append__end:
	pop %cx # [s.4] buf.len
	mov $CHR_CR, %al
	mov %al, %es:(%bx)
	mov $CHR_LF, %al
	mov %al, %es:0x01(%bx)
	add $0x02, %bx # mem
	add $0x02, %cx # his.len

	push %cx
	push $fsp+FSP_OFF_TMP
	call disk_write_fsp
	add $0x02, %sp
	pop %cx

	# {{{ update .history size
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)
	push %si
	call fsp_write
	add $0x02, %sp
	# }}}

	# {{{ fparse history
	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	push $fsp+FSP_OFF_TMP
	push %bx
	push %es
	call fparse_lines
	add $0x06, %sp

	# upd hist_idx
	mov (file_lines), %ax
	mov %ax, (hist_idx)

	# zero
	xor %ax, %ax
	mov (cl_hist_lbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_lbuf # (&off)
	push %ax # (&seg)
	call mem_set
	add $0x08, %sp
	# }}}
	# }}}}}

	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret
