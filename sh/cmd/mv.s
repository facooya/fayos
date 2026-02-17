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

	mov $arg_ccv, %si

	# (argc == 1) ? {err}
	mov (%si), %ax
	cmp $0x01, %ax
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

	mov $path_sbuf, %si
	add $0x02, %si
	mov $path_cv, %bx
	mov (%bx), %ax
	add %ax, %bx
	add %ax, %bx
	mov (%bx), %ax
	add %ax, %si

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = off>
	add %ax, %bx
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

	mov %es:DE_OFF_REC_SIZE(%bx), %cx
	pop %ax # [s.0: off]
	push %cx # (size)
	push %ax # (idx)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call fs_del
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
