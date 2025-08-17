# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read path

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global read_path

# read_path(*path)
read_path:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di

	mov 0x04(%bp), %si
	add $0x01, %si
	mov %si, %di
	xor %cx, %cx

	mov (root_inum), %ax
	mov %ax, (path_inum)

.len__lp:
	# {end} (*path[i] == null)
	mov (%si), %al
	test %al, %al
	jz .len__end

	# {end} (*path[i] == slash)
	cmp $CHR_SL, %al
	je .len__end

	# {lp}
	add $0x01, %si
	add $0x01, %cx
	jmp .len__lp

.len__end:
	push %cx # s.1 len
	push $inode
	push $path_inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	pop %cx # s.1 len

	push %si # s.1 path

	push %di
	push %cx
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp

	pop %si # s.1 path

	# {err} (lookup_dentry() == no_match)
	cmp $0x01, %ax
	je .err_inv_path
	add %ax, %bx

	# DEBUG
	push $path_inum
	call dbg_num
	add $0x02, %sp

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (path_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (path_inum+0x02)

	# DEBUG
	push $path_inum
	call dbg_num
	add $0x02, %sp

	# {done} (*path[i] == null)
	mov (%si), %al
	test %al, %al
	jz .done

	# {init.lp}
	xor %cx, %cx
	add $0x01, %si
	mov %si, %di

	jmp .len__lp

# {DONE}
.done:
	mov %bx, %ax
	mov %es, %dx
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# {ERR}
.err_inv_path:
	# DEBUG
	push %di
	call outs
	add $0x02, %sp

	jmp .exit
