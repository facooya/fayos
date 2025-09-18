# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Read path refer paths

.include "chr.s"
.include "fayfs/inode.s"
.include "fayfs/dentry.s"
.section .text
.code16
.global read_paths

# read_paths()
# <req> paths
# <ret> dx:ax = seg:off
# <ret> cx = done:0, exit:1, ne_last:2
# <info>
# si = paths
# di = path_buf
read_paths:
	push %es
	push %si
	push %di
	push %bx

	mov $paths, %si
	mov (%si), %cx # pathc
	add $0x02, %si # skip pathc

	# (pathc == 1) ? {root}
	cmp $0x01, %cx
	je .root

	mov $path_buf, %di
	add $0x02, %di
	mov (%si), %ax
	add %ax, %di

	mov (%di), %al # pathv[0]
	cmp $CHR_SL, %al
	je .abs
	jmp .lp

	# TODO: relative path

.root:
	mov (root_inum), %ax
	mov %ax, (path_inum)
	mov (root_inum+0x02), %ax
	mov %ax, (path_inum+0x02)
	mov (root_inum), %ax
	mov %ax, (parent_path_inum)
	mov (root_inum+0x02), %ax
	mov %ax, (parent_path_inum+0x02)

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
	jmp .done

.abs:
	mov (root_inum), %ax
	mov %ax, (path_inum)
	mov (root_inum+0x02), %ax
	mov %ax, (path_inum+0x02)

	# skip pathv[0]
	add $0x02, %si
	sub $0x01, %cx

.lp:
	# (pathc == 0) ? {done}
	test %cx, %cx
	jz .done

	push %cx # [s.0:pathc]
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

	# {{{ lookup dentry
	mov $path_buf, %di
	add $0x02, %di # skip buf.len
	mov (%si), %ax # pathv[i]
	add %ax, %di

	push %di
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp

	push %di
	push %ax # strlen()
	mov $inode, %di
	mov I_FILE_SIZE_OFF(%di), %ax
	push %ax # file_size
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	pop %cx # [s.0:pathc]

	# (lookup_dentry() == no_match)
	# ? {err} : off += ret
	cmp $0x01, %ax
	je .chk__err
	add %ax, %bx
	# }}}

	push %cx
	sub $0x02, %cx
	test %cx, %cx
	jz .save__parent_path_inum
	pop %cx

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (path_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (path_inum+0x02)

	# {lp}
	add $0x02, %si
	sub $0x01, %cx
	jmp .lp

.save__parent_path_inum:
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (path_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (path_inum+0x02)

	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (parent_path_inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (parent_path_inum+0x02)
	pop %cx

	# {lp}
	add $0x02, %si
	sub $0x01, %cx
	jmp .lp

.chk__err:
	sub $0x01, %cx
	test %cx, %cx
	jz .done__last

	jmp .err_inv_path

# {DONE}
.done:
	xor %cx, %cx
	mov %bx, %ax
	mov %es, %dx
	jmp .epil

.done__last:
	mov %bx, %ax
	mov %es, %dx
	mov $0x02, %cx
	jmp .epil

.exit:
	xor %ax, %ax
	xor %dx, %dx
	mov $0x01, %cx
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# {ERR}
.err_inv_path:
	push $emsg_inv_path
	call vga_puts
	add $0x02, %sp

	mov $CHR_CR, %al
	call vga_putc
	mov $CHR_LF, %al
	call vga_putc

	jmp .exit
