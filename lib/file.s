# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.section .text
.code16
.global file_parse_lines
.global file_read_pos
.global file_write_pos

# file_parse_lines(ub16 *seg, ub16 *off, fsp *src)
# <mod: file_line_cv>
file_parse_lines:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	mov 0x04(%bp), %ax
	mov %ax, %es
	mov 0x06(%bp), %bx
	mov 0x08(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %dx

	mov $file_line_cv, %di
	xor %ax, %ax
	mov %ax, (%di) # line_c

	xor %cx, %cx # line_v
	add $0x02, %di
	mov %cx, (%di) # line_v[0] # HACK
	add $0x02, %di # skip line_v[0]

1:
	# (file_size == 0) ? {done}
	test %dx, %dx
	jz 99f

	# (chr == CR) ? {line}
	mov %es:(%bx), %al
	cmp $CHR_CR, %al
	je 2f

	inc %cx # line_v
	inc %bx
	dec %dx # file_size
	jmp 1b

2: # line
	# update lines_c
	mov (file_line_cv), %ax
	inc %ax
	mov %ax, (file_line_cv)

	# store line_v
	add $0x02, %cx # skip size cr, lf
	mov %cx, (%di)
	add $0x02, %di

	# skip cr, lf
	add $0x02, %bx
	sub $0x02, %dx # file_size
	jmp 1b

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

# file_read_pos(
# ub8 *file_path,
# ub16 file_curs_pos,
# ub16 num,
# ub16 buf_seg,
# ub16 buf_off
# )
file_read_pos:
	push %bp
	mov %sp, %bp

	push $0x00 # (flag)
	push 0x0C(%bp) # (off)
	push 0x0A(%bp) # (seg)
	push 0x08(%bp) # (num)
	push 0x06(%bp) # (file_curs_pos)
	push 0x04(%bp) # (&file_path)
	call _file_rw_pos
	add $0x0C, %sp

	pop %bp
	ret

# file_write_pos(
# ub8 *file_path,
# ub16 file_curs_pos,
# ub16 data_size,
# ub16 data_seg,
# ub16 data_off
# )
file_write_pos:
	push %bp
	mov %sp, %bp

	push $0x01 # (flag)
	push 0x0C(%bp) # (off)
	push 0x0A(%bp) # (seg)
	push 0x08(%bp) # (num)
	push 0x06(%bp) # (file_curs_pos)
	push 0x04(%bp) # (&file_path)
	call _file_rw_pos
	add $0x0C, %sp

	pop %bp
	ret

# _file_rw_pos(
# ub8 *file_path,
# ub16 file_curs_pos,
# ub16 num,
# ub16 seg,
# ub16 off,
# ub16 flag
# )
_file_rw_pos:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# { path
	mov 0x04(%bp), %si # (*file_path)
	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == neq_last) ? {err}
	cmp $0x02, %ax
	je 80f
	# (path_parse() != done) ? {err} : {rw}
	test %ax, %ax
	jnz 80f
	jmp 10f
	# }

10: # read/write
	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx
	push %es # [s.l0: file_seg]

	# (flag == write) ? {wirte}
	mov 0x0E(%bp), %ax
	cmp $0x01, %ax
	je 1f

	# init read
	mov 0x06(%bp), %ax # (file_curs_pos)
	add %ax, %bx
	mov 0x08(%bp), %cx # (num)
	mov 0x0C(%bp), %di # (buf_off)
	jmp 11f

1:
	# init write
	mov 0x06(%bp), %ax # (file_curs_pos)
	add %ax, %bx
	mov 0x08(%bp), %cx # (num)
	mov 0x0C(%bp), %si # (data_off)
	jmp 12f

11: # loop read
	# (num == 0) ? {end}
	test %cx, %cx
	jz 19f

	# file -> buf
	mov %es:(%bx), %al
	push %es # [s.0: file_seg]
	mov 0x0A(%bp), %dx # (seg)
	mov %dx, %es
	mov %al, %es:(%di)
	pop %es # [s.0: file_seg]

	inc %bx
	inc %di
	dec %cx
	jmp 11b

12: # loop write
	# (num == 0) ? {end}
	test %cx, %cx
	jz 19f

	# data -> file
	push %es # [s.0: file_seg]
	mov 0x0A(%bp), %ax
	mov %ax, %es
	mov %es:(%si), %al
	pop %es # [s.0: file_seg]
	mov %al, %es:(%bx)

	inc %si
	inc %bx
	dec %cx
	jmp 12b

19:
	pop %es # [s.l0: file_seg]

	# (flag == read) ? {done}
	mov 0x0E(%bp), %ax
	test %ax, %ax
	jz 99f

	# {{ final write
	mov $fsp+FSP_OFF_BASE, %si

	# write disk
	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp

	# { upd file size
	mov FSP_OFF_F_SIZE(%si), %cx
	mov 0x06(%bp), %ax # (file_curs_pos)
	mov 0x08(%bp), %dx # (data_size)
	add %dx, %ax

	# (file_size <= (pos+size)) ? {skip} : {upd}
	cmp %ax, %cx
	jge 99f

	mov %ax, FSP_OFF_F_SIZE(%si)
	push %si
	call fsp_write
	add $0x02, %sp
	jmp 99f
	# }
	# }}

80:
	# TODO: error handler
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

.section .data
.global file_line_cv
file_line_cv: .zero 0x100
