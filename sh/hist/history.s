# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Shell history

.include "chr.s"
.include "drv/disk.s"
.include "fs/dentry.s"
.include "fs/inode.s"
.include "fs/ind.s"

# TODO: history/cache.s
.section .data
.global hist_idx
hist_idx: .word 0x00

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

	# { lookup dentry
	mov $de_hist, %si
	xor %cx, %cx
	mov (%si), %ax
	mov %al, %cl
	add $0x02, %si
	push %si
	push %cx
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	# }

	# {task} (lookup_dentry == no_match)
	cmp $0x01, %ax
	je .create

	add %ax, %bx
	jmp .save

.create:
	call ind_add
	# <dx:ax = inum_hi:inum_lo>
	mov %ax, (tmp_inum)
	mov %dx, (tmp_inum+0x02)

	mov $de_hist, %si
	mov (%si), %cx
	add $0x02, %si
	push %si # name
	push %cx # info
	push $root_inum # src
	push $tmp_inum # dest
	call add_dentry
	add $0x08, %sp
	push %ax # [s.1] dentry_size

	# {{{ update root file size
	push $inode
	push $root_inum
	call ind_read
	add $0x04, %sp

	pop %ax # [s.1] dentry size
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $root_inum
	call ind_upd
	add $0x04, %sp
	# }}}

	jmp .save

.save:
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
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	add %ax, %bx

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (tmp_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (tmp_inum+0x02)

	push $inode
	push $tmp_inum
	call ind_read
	add $0x04, %sp

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax # [s.2] file_size

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

	pop %ax # [s.2] file_size
	add %ax, %bx
	push %ax # [s.3] file_size

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
	push %cx # [s.5] his.len

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

	# {{{ update .history size
	push $inode
	push $tmp_inum
	call ind_read
	add $0x04, %sp

	pop %cx # [s.5] his.len
	pop %ax # [s.3] file_size
	add %ax, %cx
	mov $inode, %si
	mov %cx, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call ind_upd
	add $0x04, %sp
	# }}}

	# {{{{{ TODO: optimize
	# {{{ read root content
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
