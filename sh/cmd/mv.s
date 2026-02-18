# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "fs/de.inc"
.section .text
.code16
.global cmd_mv

# cmd_mv()
# <ret: ax = code>
cmd_mv:
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

	push %ax # [s.0: off]
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

	pop %ax # [s.0: off]
	mov %es:DE_OFF_REC_SIZE(%bx), %cx
	push %cx # (size)
	push %ax # (idx)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call fs_del
	add $0x06, %sp

	mov $arg_ccv, %si
	mov 0x08(%si), %ax # argv[2]
	mov $cl_sbuf, %si
	add $0x02, %si
	add %ax, %si # cl_sbuf[argv[2]]

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

	# TODO: dst = dir ?

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
