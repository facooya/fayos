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

# fs_read_path()
# <req> path_cv
# <ret> dx:ax = seg:off
# <ret> cx = done:0, exit:1, ne_last:2
# <info>
# si = path_cv
# di = path_sbuf
fs_read_path:
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
	mov $indp+INDP_OFF_PATH, %di
	push (root_inum) # (inum_lo)
	push (root_inum+0x02) # (inum_hi)
	push %di # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push IND_OFF_BLK_0(%di)
	push IND_OFF_BLK_0+0x02(%di)
	call fs_blk_to_lba
	add $0x02, %sp

	mov $dp+DP_OFF_PATH, %di
	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)

	push %di
	#call disk_read_dp
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	jmp .done

.abs:
	mov (root_inum), %ax
	mov (root_inum+0x02), %dx

	# skip pathv[0]
	add $0x02, %si
	sub $0x01, %cx

.lp:
	# (pathc == 0) ? {done}
	test %cx, %cx
	jz .done

	push %cx # [s.0:pathc]

	mov $indp+INDP_OFF_PATH, %di
	push %ax # (inum_lo)
	push %dx # (inum_hi)
	push %di # (fsp &dst)
	call fsp_read
	add $0x06, %sp

	push IND_OFF_BLK_0(%di)
	push IND_OFF_BLK_0+0x02(%di)
	call fs_blk_to_lba
	add $0x04, %sp

	mov $dp+DP_OFF_PATH, %di
	mov %dx, DP_OFF_LBA+0x02(%di)
	mov %ax, DP_OFF_LBA(%di)

	push %di
	#call disk_read_dp
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx

	mov $path_sbuf, %di
	add $0x02, %di # skip bufs
	mov (%si), %ax # pathv[i]
	add %ax, %di

	push %di # (&name)
	push $fsp+FSP_OFF_CUR # (fsp &src)
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
