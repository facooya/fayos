# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Shell history

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"

# TODO: history/cache.s
.section .data
.global hist_stack
hist_stack: .word 0x00

.section .text
.code16
.global history

# history()
# <req> raw_buf
history:
	push %si
	push %bx

	push $inode
	push $root_inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds

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
	call lookup_dentry
	add $0x08, %sp

	# {task} (lookup_dentry == no_match)
	cmp $0x01, %ax
	je .create

	add %ax, %bx

	jmp .save

.create:
	call add_inode
	# <ret> tmp_inum

	mov $de_hist, %si
	mov (%si), %cx
	add $0x02, %si
	push %si # name
	push %cx # info
	push $tmp_inum # dst
	push $root_inum # src
	call add_dentry
	add $0x08, %sp
	push %ax # [s.1] dentry_size

	# {{{ update root file size
	push $inode
	push $root_inum
	call read_inode
	add $0x04, %sp

	pop %ax # [s.1] dentry size
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $root_inum
	call update_inode
	add $0x04, %sp
	# }}}

	jmp .save

.save:
	push $inode
	push $root_inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %ds

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
	call lookup_dentry
	add $0x08, %sp
	add %ax, %bx

	mov DE_INUM_OFF(%bx), %ax
	mov %ax, (tmp_inum)
	mov DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (tmp_inum+0x02)

	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax # [s.2] file_size

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx # mem
	mov %dx, %ds
	pop %ax # [s.2] file_size
	add %ax, %bx
	push %ax # [s.3] file_size

.append:
	mov $raw_buf, %si
	mov (%si), %cx # buf.len
	push %cx # [s.4] buf.len
	add $0x02, %si # skip len

.append__lp:
	mov (%si), %al

	# {end} (len == 0)
	test %cx, %cx
	jz .append__end

	mov %al, (%bx)

	# {lp}
	add $0x01, %si # buf.data
	add $0x01, %bx # mem
	sub $0x01, %cx # buf.len
	jmp .append__lp

.append__end:
	pop %cx # [s.4] buf.len
	mov $CHR_CR, (%bx)
	mov $CHR_LF, 0x01(%bx)
	add $0x02, %bx # mem
	add $0x02, %cx # his.len
	push %cx # [s.5] his.len

	push $dap
	call write_disk
	add $0x02, %sp

	# {{{ update .history size
	push $inode
	push $tmp_inum
	call read_inode
	add $0x04, %sp

	pop %cx # [s.5] his.len
	pop %ax # [s.3] file_size
	add %ax, %cx
	mov $inode, %si
	mov %cx, I_FILE_SIZE_OFF(%si)

	push $inode
	push $tmp_inum
	call update_inode
	add $0x04, %sp
	# }}}

	xor %ax, %ax
	mov %ax, %ds
	jmp .done

.done:
	pop %bx
	pop %si
	ret
