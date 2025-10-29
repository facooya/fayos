# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Shell history

.include "chr.s"
.include "fs/fs.s"
.include "drv/disk.s"
.include "fs/dentry.s"
.include "fs/inode.s"
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
	# <ax = {true:off, false:1}
	add %ax, %bx

	mov %es:DE_INUM_OFF(%bx), %ax
	push %ax
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	push %ax
	push $fsp+FSP_OFF_TMP
	call fsp_read
	add $0x06, %sp

	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

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

	# {{{ update .history size
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_IND_FILE_SIZE(%si), %ax
	add %cx, %ax
	mov %ax, FSP_OFF_IND_FILE_SIZE(%si)
	push %si
	call fsp_write
	add $0x02, %sp
	jmp .done # HACK
	# }}}

	# {{{{{ TODO: optimize
	# {{{ read root content
	push $inode
	push $root_inum
	call ind_read_old
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
	# }}}

	# {{{ lookup history
	mov $de_hist, %di
	xor %cx, %cx
	mov (%di), %ax
	mov %al, %cl
	add $0x02, %di
	push %di
	push %cx
	mov $inode, %di
	mov I_FILE_SIZE_OFF(%di), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	add %ax, %bx
	# }}}

	# {{{ read history file
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (tmp_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (tmp_inum+0x02)

	push $inode
	push $tmp_inum
	call ind_read_old
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
	# }}}

	# {{{ fparse
	push $inode
	push %bx
	push %es
	call fparse_lines
	add $0x06, %sp

	# upd hist_idx
	mov (file_lines), %ax
	mov %ax, (hist_idx)
	# }}}
	# }}}}}

	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret
