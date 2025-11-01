# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [File System] Read path

.include "chr.s"
.include "drv/disk.s"
.include "fs/fs.s"
.include "fs/ind.s"
.include "fs/de.s"
.section .text
.code16
.global fs_read_path

# fs_read_path(fsp *dst)
# <req> fsp *root, path_cv, path_sbuf
# <ret> ax = {done:0, exit:1, ne_last:2}
fs_read_path:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov $path_cv, %si
	mov (%si), %cx # pathc
	add $0x02, %si # skip pathc

	# (pathc == 1) ? {root}
	cmp $0x01, %cx
	je .root

	mov $path_sbuf, %di
	add $0x02, %di
	mov (%si), %ax
	add %ax, %di

	mov (%di), %al # pathv[0]
	cmp $CHR_SL, %al
	je .abs
	jmp .lp

	# TODO: relative path

.root:
	mov $fsp+FSP_OFF_ROOT, %di
	mov FSP_OFF_INUM(%di), %ax
	mov FSP_OFF_INUM+0x02(%di), %dx
	jmp .done

.abs:
	mov $(FS_ROOT_INUM>>0x10), %dx
	mov $(FS_ROOT_INUM&0xFFFF), %ax

	# skip pathv[0]
	add $0x02, %si
	sub $0x01, %cx

.lp:
	# (pathc == 0) ? {done}
	test %cx, %cx
	jz .done

	push %cx # [s.0:pathc]
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push 0x04(%bp) # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push 0x04(%bp) # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	mov $path_sbuf, %di
	add $0x02, %di # skip bufs
	mov (%si), %ax # pathv[i]
	add %ax, %di

	push %di # (&name)
	push 0x04(%bp) # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = true:off, false:1>
	pop %cx # [s.f0:pathc]

	# (de_seek() == false) ? {err} : off+=ret
	cmp $0x01, %ax
	je .chk__err
	add %ax, %bx
	# }}}

	mov %es:DE_OFF_INUM(%bx), %ax
	mov %es:DE_OFF_INUM+0x02(%bx), %dx

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
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push 0x04(%bp) # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	xor %ax, %ax
	jmp .epil

.done__last:
	mov $0x02, %ax
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
