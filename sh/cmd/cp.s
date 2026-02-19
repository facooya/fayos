# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "fs/de.inc"
.section .text
.code16
.global cmd_cp

# cmd_cp()
# <ret: ax = code>
cmd_cp:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	# (argc != 2) ? {err}
	mov $arg_ccv, %si
	mov (%si), %ax
	cmp $0x02, %ax
	je 8001f

	mov 0x06(%si), %ax # argv[1]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[1]]

	# { path
	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je 8002f
	# (path_parse() == neq_last) ? {err}
	cmp $0x02, %ax
	je 8003f
	# }

	# TODO: chk dir

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# { de_seek
	mov $path_sbuf, %si
	add $0x02, %si
	mov $path_cv, %di
	mov (%di), %ax
	add %ax, %di
	add %ax, %di
	mov (%di), %ax
	add %ax, %si

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = off>
	add %ax, %bx
	# }

	mov %es:DE_OFF_REC_SIZE(%bx), %cx
	push %cx # (size)
	push %ax # (idx)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call fs_read
	add $0x06, %sp

	mov %es:DE_OFF_REC_SIZE(%bx), %cx
	push %cx # (size)
	push $fs_read_buf # (s_off)
	push %ds # (s_seg)
	push $_dentry_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov $arg_ccv, %si
	mov 0x08(%si), %ax # argv[2]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[2]]

	push %si # [s.0: cl_sbuf]
	mov $fsp+FSP_OFF_BASE, %si
	xor %ax, %ax
	mov FSP_OFF_F_TYPE(%si), %al
	mov %ax, -0x04(%bp) # (l.2: f_type)
	mov FSP_OFF_BLK_CNT(%si), %al
	mov %ax, -0x06(%bp) # (l.3: blk_cnt)
	mov FSP_OFF_BLK(%si), %ax
	mov %ax, -0x08(%bp) # (l.4: blk)
	pop %si # [s.0: cl_sbuf]

	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_BASE # (s_off)
	push %ds # (s_seg)
	push $fsp+FSP_OFF_TMP # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	# { path dst
	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je 8002f
	# }

	# { inode
	mov -0x04(%bp), %ax # (l.2: f_type)
	push %ax # (f_type)
	call ind_add
	add $0x02, %sp
	# <ax = inum>
	mov %ax, -0x02(%bp) # (l.1: inum)
	# }

	push %ax # (inum)
	push $fsp+FSP_OFF_BASE # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	mov $fsp+FSP_OFF_TMP, %si
	mov $fsp+FSP_OFF_BASE, %di
	mov FSP_OFF_F_SIZE(%si), %ax
	mov %ax, FSP_OFF_F_SIZE(%di)
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call fsp_write
	add $0x02, %sp

	# { cpy blk
	mov -0x08(%bp), %ax # (l.4: blk)
	push %ax
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>

	mov $fsp+FSP_OFF_TMP, %si
	mov %ax, FSP_OFF_DISK_LBA(%si)
	push $fsp+FSP_OFF_TMP
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_read_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $fsp+FSP_OFF_BASE
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push $fs_read_buf # (s_off)
	push %ds # (s_seg)
	push %bx # (d_off)
	push %es # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $fsp+FSP_OFF_BASE
	call disk_write_fsp
	add $0x02, %sp
	# }

	# TODO: loop blk_cnt alloc blk

	# { name
	mov $path_sbuf, %si
	add $0x02, %si
	mov $path_cv, %bx
	mov (%bx), %ax
	add %ax, %bx
	add %ax, %bx
	mov (%bx), %ax
	add %ax, %si

	push %si # (off)
	push %ds # (seg)
	call mem_size
	add $0x04, %sp
	# <ax = size>
	# }

	# { dentry
	mov $_dentry_buf, %di
	mov -0x02(%bp), %dx # (l.1: inum)
	mov %dx, DE_OFF_INUM(%di)
	mov %al, DE_OFF_NAME_SIZE(%di)
	mov %ax, %cx
	add $(DE_SIZE+DE_ALIGN_2), %cx
	and $DE_MASK, %cx
	mov %cx, DE_OFF_REC_SIZE(%di)
	add $DE_OFF_NAME, %di

	push %ax # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	# }

	mov $_dentry_buf, %si
	mov DE_OFF_REC_SIZE(%si), %cx
	push %cx # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	push $fs_write_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov $fsp+FSP_OFF_DIR, %si
	mov FSP_OFF_F_SIZE(%si), %ax
	mov $_dentry_buf, %si
	mov DE_OFF_REC_SIZE(%si), %cx
	push %cx # (size)
	push %ax # (idx)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call fs_write
	add $0x06, %sp
	jmp 90f

80:
	mov $0x01, %ax
	jmp 99f

90:
	xor %ax, %ax
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	mov %bp, %sp
	pop %bp
	ret

8001:
	push $emsg_arg_req
	jmp 8090f

8002:
	push $emsg_inv_path
	jmp 8090f

8003:
	push $emsg_file_no
	jmp 8090f

8090:
	call vga_outs
	add $0x02, %sp
	NEWLINE
	jmp 80b

.section .data
_dentry_buf: .zero 0x0200
