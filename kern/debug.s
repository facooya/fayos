# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "drv/vga.inc"
.section .text
.code16
.global dbg_out
.global dbg_a
.global dbg_b
.global dbg_c
.global dbg_sbuf
.global dbg_reg
.global dbg_num
.global dbg_arg_ccv
.global dbg_path_cv
.global dbg_curs
.global dbg_fsp
.global dbg_file

# dbg_out()
# <req: al = chr>
dbg_out:
	push %es
	push %di
	push %ax

	mov $0xB800, %ax
	mov %ax, %es
	xor %di, %di

	pop %ax
	push %ax

	mov $0x07, %ah
	mov %ax, %es:(%di)

	pop %ax
	pop %di
	pop %es
	ret

# dbg_a()
dbg_a:
	push %ax
	push %cx
	push %dx
	call _trace_prol
	mov $0x41, %al
	jmp 90f

# dbg_b()
dbg_b:
	push %ax
	push %cx
	push %dx
	call _trace_prol
	mov $0x42, %al
	jmp 90f

# dbg_c()
dbg_c:
	push %ax
	push %cx
	push %dx
	call _trace_prol
	mov $0x43, %al
	jmp 90f

90:
	call vga_outc
	mov $CHR_SP, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %cx
	pop %ax
	ret

# dbg_sbuf(ub8 *sbuf)
dbg_sbuf:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %bx
	push %cx
	push %dx

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	mov 0x04(%bp), %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	mov %cx, %ax # buf.len
	add $0x30, %al
	push %cx
	call vga_outc
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %cx

	call _data

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %si
	pop %bp
	ret

# dbg_reg(ub16 reg)
dbg_reg:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %bx
	push %cx
	push %dx

	call _line

	mov $_outnum, %si
	add $0x03, %si # last to first

	mov 0x04(%bp), %bx # num
	mov $0x04, %cx # count

1:
	mov %bx, %ax # num
	and $0x0F, %al # mask

	# (al > 9)
	cmp $0x09, %al
	jg 2f

	add $0x30, %al
	jmp 3f

2: # hex
	add $0x37, %al

3: # step
	mov %al, (%si)
	dec %si

	# (count == 0) ? {end} : {loop}
	dec %cx
	test %cx, %cx
	jz 90f

	shr $0x04, %bx
	jmp 1b

90:
	push $_outnum
	call vga_outs
	add $0x02, %sp

	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %si
	pop %bp
	ret

# dbg_num(ub32 *num)
dbg_num:
	push %bp
	mov %sp, %bp
	push %si
	push %ax
	push %dx

	call _line

	mov 0x04(%bp), %si
	mov 0x02(%si), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call vga_outc
	mov %dl, %al
	call vga_outc

	mov (%si), %dx
	add $0x30, %dh
	add $0x30, %dl
	mov %dh, %al
	call vga_outc
	mov %dl, %al
	call vga_outc

	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %ax
	pop %si
	pop %bp
	ret

# dbg_arg_ccv()
dbg_arg_ccv:
	push %si
	push %di
	push %ax
	push %bx
	push %cx
	push %dx

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	mov $cl_sbuf, %si
	mov (%si), %bx
	add $0x02, %si

	push $_arg_c_str
	call vga_outs
	add $0x02, %sp

	# get arg_c
	mov $arg_ccv, %di
	mov (%di), %cx # arg_c
	add $0x02, %di # skip arg_c
	push %cx # [s.0:arg_c]

	# byte to ascii
	mov %cx, %ax
	add $0x30, %al

	# arg_c
	call vga_outc
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	push $_opt_c_str
	call vga_outs
	add $0x02, %sp

	# get opt_c
	mov (%di), %ax # opt_c
	add $0x02, %di # skip opt_c

	# byte to ascii
	add $0x30, %al

	# opt_c
	call vga_outc
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %cx # [s.0:arg_c]

	# (arg_c == 0) ? {done}
	test %cx, %cx # arg_c
	jz 90f

	xor %dx, %dx # idx

1:
	push %cx # [s.0:arg_c]
	push %dx # [s.1:idx]
	# {{{ out str
	push $_arg_v_str
	call vga_outs
	add $0x02, %sp
	pop %dx # [s.1:idx]
	push %dx # [s.1:idx]

	# idx
	mov %dl, %al # idx
	add $0x30, %al
	call vga_outc

	push $_arg_v_end_str
	call vga_outs
	add $0x02, %sp
	# }}}

	# {{{
	# {init}
	mov $cl_sbuf, %si
	add $0x02, %si # skip size

	# calc offset
	mov (%di), %ax # arg_v[i]
	add %ax, %si

	push %si
	call vga_outs
	add $0x02, %sp
	# }}}
	pop %dx # [s.1:idx]
	pop %cx # [s.0:arg_c]

	add $0x02, %di # arg_v
	dec %cx # arg_c
	inc %dx # idx

	# (arg_c == 0) ? {done}
	test %cx, %cx
	jz 90f

	push %cx # [s.f0:arg_c]
	push %dx # [s.f1:idx]
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %dx # [s.f1:idx]
	pop %cx # [s.f0:arg_c]
	jmp 1b

90:
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret

# dbg_path_cv()
dbg_path_cv:
	push %si
	push %di
	push %ax
	push %bx
	push %cx
	push %dx

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	# { pathc
	mov $path_cv, %si
	mov (%si), %cx
	add $0x02, %si

	push %cx # [s.f0:pathc]
	push $_pathc_str
	call vga_outs
	add $0x02, %sp
	pop %cx # [s.f0:pathc]

	push %cx # [s.f0:pathc]
	mov %cx, %ax
	add $0x30, %al
	call vga_outc

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %cx # [s.f0:pathc]
	# }

	xor %dx, %dx # pathv idx

1:
	# { pathv idx
	push %cx # [s.0:pathc]
	push %dx # [s.1:pathv]

	push $_pathv_str
	call vga_outs
	add $0x02, %sp

	pop %dx # [s.1:pathv]
	push %dx # [s.1:pathv]

	mov %dl, %al
	add $0x30, %al
	call vga_outc

	push $_pathv_end_str
	call vga_outs
	add $0x02, %sp
	# }

	# { path out
	mov $path_sbuf, %di
	add $0x02, %di # skip bufc

	mov (%si), %ax
	add %ax, %di

	push %di
	call vga_outs
	add $0x02, %sp
	# }
	pop %dx # [s.1:pathv]
	pop %cx # [s.0:pathc]

	add $0x02, %si
	dec %cx
	inc %dx

	# (pathc == 0) ? {done} : {lp}
	test %cx, %cx
	jz 90f

	push %cx
	push %dx
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	pop %dx
	pop %cx
	jmp 1b

90:
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %dx
	pop %cx
	pop %bx
	pop %ax
	pop %di
	pop %si
	ret

# dbg_curs()
dbg_curs:
	push %si
	
	mov $curs, %si

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	mov (%si), %al
	add $0x30, %al
	call vga_outc

	mov 0x01(%si), %al
	add $0x30, %al
	call vga_outc

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %si
	ret

# dbg_fsp(fsp *src)
dbg_fsp:
	push %bp
	mov %sp, %bp
	push %si
	push %ax

	mov 0x04(%bp), %si

	mov FSP_OFF_F_SIZE(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	mov FSP_OFF_F_TYPE(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	mov FSP_OFF_BLK(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $_ind_ptr_str
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	mov FSP_OFF_IND_PTR+0x02(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp
	mov FSP_OFF_IND_PTR(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $_inum_str
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	mov FSP_OFF_INUM(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	push $_disk_lba_str
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	mov FSP_OFF_DISK_LBA(%si), %ax
	push %ax
	call dbg_reg
	add $0x02, %sp

	pop %ax
	pop %si
	pop %bp
	ret

# dbg_file(ub8 *path)
dbg_file:
	push %bp
	mov %sp, %bp
	push %es
	pusha

	mov 0x04(%bp), %si

	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp *dir, *base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	push $fsp+FSP_OFF_BASE # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx
	push %es # [s.0: file_seg]

	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_SIZE(%si), %cx

	mov $(VGA_MEM>>0x10), %ax
	mov %ax, %es
	mov $(VGA_MEM&0xFFFF), %di

1:
	# (cnt == 0) ? {end}
	test %cx, %cx
	jz 9f

	pop %es # [s.0: file_seg]
	mov %es:(%bx), %al
	push %es # [s.0: file_seg]

	mov $(VGA_MEM>>0x10), %dx
	mov %dx, %es
	mov $VGA_ATTR_COLOR, %ah
	mov %ax, %es:(%di)

	add $0x02, %di
	inc %bx
	dec %cx
	jmp 1b

9:
	pop %es # [s.0: file_seg]

	popa
	pop %es
	pop %bp
	ret

# _data()
_data:
	# {end} (buf.len == 0)
	test %cx, %cx # buf.len
	jz 99f

1:
	mov (%si), %al

	# (buf.data == sp)
	cmp $CHR_SP, %al
	je 2f

	# (buf.data == null)
	test %al, %al
	jz 3f

	push %cx
	call vga_outc
	pop %cx
	jmp 9f

2: # space
	mov $CHR_PRD, %al
	push %cx
	call vga_outc
	pop %cx
	jmp 9f

3: # null
	mov $CHR_ZERO, %al
	push %cx
	call vga_outc
	pop %cx
	jmp 9f

9:
	inc %si # buf.data
	dec %cx # buf.size

	# (buf.size == 0) ? {end} : {loop}
	test %cx, %cx
	jz 99f
	jmp 1b

99:
	ret

# _trace_prol()
_trace_prol:
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	call _line
	mov $CHR_SP, %al
	call vga_outc
	ret

# _line()
_line:
	push %ax
	push %cx
	push %dx
	mov $0x05, %cx

1:
	test %cx, %cx
	jz 99f

	push %cx
	mov $CHR_EQ, %al
	call vga_outc
	pop %cx

	dec %cx
	jmp 1b

99:
	pop %dx
	pop %cx
	pop %ax
	ret

.section .data
_outnum: .zero 0x05
_arg_c_str: .asciz "arg_c: "
_opt_c_str: .asciz "opt_c: "
_arg_v_str: .asciz "arg_v["
_arg_v_end_str: .asciz "]: "
_pathc_str: .asciz "pathc: "
_pathv_str: .asciz "pathv["
_pathv_end_str: .asciz "]: "
_ind_ptr_str: .asciz "ind_ptr"
_inum_str: .asciz "inum"
_disk_lba_str: .asciz "disk_lba"
