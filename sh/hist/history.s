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

.section .data
.global hist_idx
hist_idx: .word 0x00
.fpath_hist: .asciz "/.history"

.section .text
.code16
.global history

# history()
# <req> cl_sbuf
history:
	push %es
	push %si
	push %di
	push %bx

	# { path
	push $.fpath_hist # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == neq_last) ? {create}
	cmp $0x02, %ax
	je .create
	# (path_parse() != done) ? {done} : {save}
	test %ax, %ax
	jnz .done
	# }

	# cpy base -> tmp
	xor %ax, %ax
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_BASE # (&s_off)
	push %ax # (&s_seg)
	push $fsp+FSP_OFF_TMP # (&d_off)
	push %ax # (&d_seg)
	call mem_cpy
	add $0x0A, %sp
	jmp .save

.create:
	push $F_TYPE_FILE # (f_type)
	push $.fpath_hist # (&name)
	call fs_add
	add $0x04, %sp
	# <mod: fsp *tmp>
	jmp .save

.save:
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	add %ax, %bx

.append:
	mov $cl_sbuf, %si
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
	mov (cl_hist_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $cl_hist_sbuf # (&off)
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
