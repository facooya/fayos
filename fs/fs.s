# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/disk.inc"
.include "fs/sb.inc"
.include "fs/fs.inc"
.include "fs/ind.inc"
.include "fs/de.inc"
.section .text
.code16
.global fs_add
.global fs_rm
.global fs_read
.global fs_write
.global fs_blk_to_lba
.global fs_del

# fs_add(ub8 *path, ub16 f_type)
# <req: fsp {dir, par, cur, tmp}, path_cv, path_sbuf>
# <ret: ax = {done:0, exit:1}>
fs_add:
	push %bp
	mov %sp, %bp
	push %es
	push %si
	push %di
	push %bx

	# { path
	push 0x04(%bp) # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je 803f # inv_path
	# (path_parse() != neq_last) ? {err}
	cmp $0x02, %ax
	jne 801f # name dup
	# }

	# { chk name
	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	push %si # (off)
	push %ds # (seg)
	call regex_name
	add $0x04, %sp
	# <ax = {true:0, false:1}>

	cmp $0x01, %ax
	je 802f # name inv
	# }

	push 0x06(%bp) # (f_type)
	call ind_add
	add $0x02, %sp
	# <ax = inum>

	push %ax # (inum)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	# { de_add
	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	push 0x06(%bp) # (f_type)
	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add
	add $0x08, %sp
	# }

	# { upd f_size if fsp_dir is fsp_cur, fsp_par
	mov $fsp+FSP_OFF_CUR, %si
	push FSP_OFF_INUM(%si)
	push $fsp+FSP_OFF_CUR
	call fsp_read
	add $0x04, %sp

	mov $fsp+FSP_OFF_PAR, %si
	push FSP_OFF_INUM(%si)
	push $fsp+FSP_OFF_PAR
	call fsp_read
	add $0x04, %sp
	# }

	# (f_type != dir) ? {done} : {add_dots}
	mov 0x06(%bp), %ax
	cmp $F_TYPE_DIR, %ax
	jne 90f

	push $fsp+FSP_OFF_DIR # (fsp &src)
	push $fsp+FSP_OFF_TMP # (fsp &dst)
	call de_add_dots
	add $0x04, %sp

90: # done
	xor %ax, %ax
	jmp 99f

80: # exit
	mov $0x01, %ax
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	pop %bp
	ret

801: # name dup
	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	xor %ax, %ax
	push %si # (&off)
	call vga_outs
	add $0x02, %sp

	push $CHR_COL
	call vga_outc
	add $0x02, %sp
	push $CHR_SP
	call vga_outc
	add $0x02, %sp

	push $emsg_name_dup
	jmp 890f

802: # name inv
	push $emsg_name_inv
	jmp 890f

803: # path inv
	push $emsg_inv_path
	jmp 890f

890: # err hdl
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b # exit

# fs_rm(ub8 *path, ub8 f_type)
# <req: fsp {base, dir, cur}, path_sbuf>
# <mod: fsp tmp, path_cv>
# <ret: ax = {done:0, exit:1}>
fs_rm:
	push %bp
	mov %sp, %bp
	push %si
	push %di
	push %bx

	# { path
	push 0x04(%bp) # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je 801f # path inv
	# (path_parse() != neq_last) ? {pass}
	cmp $0x02, %ax
	jne 2f

	# (f_type == file) ? {err.file}
	mov 0x06(%bp), %ax # (f_type)
	cmp $F_TYPE_FILE, %al
	je 802f # file no
	# (f_type == dir) ? {err.dir} : {err.path}
	cmp $F_TYPE_DIR, %al
	je 804f # dir no
	jmp 801f # path inv
	# }

1:
	mov 0x06(%bp), %ax # (f_type)
	cmp $F_TYPE_FILE, %al
	je 803f # file type
	cmp $F_TYPE_DIR, %al
	je 805f # dir type
	jmp 80f

2: # chk type
	xor %ax, %ax
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_TYPE(%si), %al
	mov 0x06(%bp), %cx # (f_type)
	cmp %al, %cl
	jne 1b # err

	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx
	mov %ax, -0x02(%bp) # (l.1: idx)

	# (f_type == dir) ? {dir}
	mov %es:DE_OFF_F_TYPE(%bx), %al
	cmp $F_TYPE_DIR, %al
	je 11f

	# (f_type == file) ? {file} : {exit}
	cmp $F_TYPE_FILE, %al
	je 10f
	jmp 80f

10: # file rm
	mov %es:DE_OFF_INUM(%bx), %ax
	jmp 70f

11: # chk entry
	# (path_c == 1) ? {chk}
	mov $path_cv, %si
	mov (%si), %ax
	cmp $0x01, %ax
	je 12f
	jmp 20f

12: # chk dot
	mov $path_sbuf, %si
	add $0x02, %si
	mov (%si), %ax
	cmp $0x002E, %ax
	je 806f # dir self
	cmp $0x2E2E, %ax
	je 13f
	jmp 20f
	# }}}

13: # chk dots
	mov 0x02(%si), %al
	test %al, %al
	jz 806f # dir self
	jmp 20f

20: # down
	mov $fsp+FSP_OFF_TMP, %si
	mov %es:DE_OFF_INUM(%bx), %ax
	push %ax # (inum)
	push %si # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	add $DIR_DOTS_REC_SIZE, %bx
	mov $DIR_DOTS_REC_SIZE, %cx

	mov FSP_OFF_F_SIZE(%si), %dx
	sub $DIR_DOTS_REC_SIZE, %dx
	cmp $0x00, %dx
	jle 40f

30:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	jz 31f

	# (f_type == dir) ? {chk}
	mov %es:DE_OFF_F_TYPE(%bx), %al
	cmp $F_TYPE_DIR, %al
	je 32f

31:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx # mem
	add %ax, %cx # rec_size

	# (file_size <= 0) ? {end} : {lp}
	sub %ax, %dx # f_size
	cmp $0x00, %dx
	jle 40f
	jmp 30b

32:
	push %dx # [s.f0:f_size]
	push %cx # [s.f1:rec_size]
	mov %es:DE_OFF_INUM(%bx), %ax
	push %ax # (inum)
	push $fsp+FSP_OFF_BASE # (fsp &dst) HACK
	call fsp_read
	add $0x04, %sp
	pop %cx # [s.f1:rec_size]
	pop %dx # [s.f0:f_size]

	# (f_size == dots) ? {find_step} : {down_lp}
	mov $fsp+FSP_OFF_BASE, %di # HACK
	mov FSP_OFF_F_SIZE(%di), %ax
	cmp $DIR_DOTS_REC_SIZE, %ax
	je 31b
	jmp 20b

40:
	mov $fsp+FSP_OFF_TMP, %si
	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# { pre upd
	mov FSP_OFF_F_SIZE(%si), %dx
	mov $DIR_DOTS_REC_SIZE, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)

	push %ax # [s.f0:dots_size]
	push %dx # [s.f1:f_size]
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp
	pop %dx # [s.f1:f_size]
	pop %ax # [s.f0:dots_size]
	# }

	mov %ax, %cx # pos = dots
	sub %ax, %dx # f_size - dots
	add %ax, %bx # mem + dots

50:
	# (inum == 0) ? {step}
	mov %es:DE_OFF_INUM(%bx), %ax
	test %ax, %ax
	jz 51f

	push %cx # [s.0:rec_size]
	push %dx # [s.1:f_size]
	push %es:DE_OFF_INUM(%bx) # (inum)
	call ind_clr
	add $0x02, %sp

	# clr inum
	xor %ax, %ax
	mov %ax, %es:DE_OFF_INUM(%bx)

	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp
	pop %dx # [s.1:f_size]
	pop %cx # [s.0:rec_size]

51:
	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	add %ax, %bx
	add %ax, %cx
	sub %ax, %dx

	# (f_size <= 0) ? {end} : {lp}
	cmp $0x00, %dx
	jle 52f
	jmp 50b

52:
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $path_cv, %si
	mov (%si), %ax
	add %ax, %si
	add %ax, %si
	mov (%si), %ax
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si

	push %si # (&name)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call de_seek
	add $0x04, %sp
	# <ax = {true:off, false:1}>
	add %ax, %bx

	# (del_inum != sel_inum) ? {dir.down} : {clr}
	mov %es:DE_OFF_INUM(%bx), %ax
	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_INUM(%si), %cx
	cmp %ax, %cx
	jne 20b

70: # last rm
	push %ax # (inum)
	call ind_clr
	add $0x02, %sp

	mov %es:DE_OFF_REC_SIZE(%bx), %ax
	mov -0x02(%bp), %cx # (l.1: idx)
	push %ax # (size)
	push %cx # (idx)
	push $fsp+FSP_OFF_DIR # (fsp &src)
	call fs_del
	add $0x06, %sp

	# {{ chk cur
	mov $fsp+FSP_OFF_CUR, %si
	push FSP_OFF_INUM(%si) # (inum)
	push $fsp+FSP_OFF_CUR # (fsp &dst)
	call fsp_read
	add $0x04, %sp

	mov FSP_OFF_F_TYPE(%si), %al
	cmp $F_TYPE_RM, %al
	jne 90f

	# { upd cur
	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_DIR # (s_off)
	push %ds # (s_seg)
	push $fsp+FSP_OFF_CUR # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov (path_cv), %ax
	dec %ax
	mov %ax, (path_cv)
	call cwd_build
	# <req: path_cv, path_sbuf>
	# <mod: cwd>

	call ps1_build
	# }
	# }}

90: # done
	xor %ax, %ax # <ret.0:ret_code>
	jmp 99f

80: # exit
	mov $0x01, %ax # <ret.1:ret_code>
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %bp
	ret

801: # path inv
	push $emsg_inv_path
	jmp 890f

802: # file no
	call _err_print_name
	push $emsg_file_no
	jmp 890f

803: # file type
	push $emsg_file_type
	jmp 890f

804: # dir no
	call _err_print_name
	push $emsg_dir_no
	jmp 890f

805: # dir type
	push $emsg_dir_type
	jmp 890f

806: # dir self
	push $emsg_dir_self
	jmp 890f

890: # err hdl
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b

# _err_print_name()
# <req: path_cv, path_sbuf>
_err_print_name:
	mov $path_cv, %si
	mov (%si), %ax # pathc
	add %ax, %si
	add %ax, %si
	mov (%si), %ax # pathv[last]
	mov $path_sbuf, %si
	add $0x02, %si
	add %ax, %si # name

	xor %ax, %ax
	push %si # (&off)
	call vga_outs
	add $0x02, %sp

	push $CHR_COL
	call vga_outc
	add $0x02, %sp
	push $CHR_SP
	call vga_outc
	add $0x02, %sp
	ret

# fs_read(
# fsp *src,
# ub16 idx,
# ub16 size
# )
# <ro: (dpi bbm)>
# <rw: fs_buf>
# <ret: ax = code, fs_read_buf>
fs_read:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	# { chk size
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %dx # (idx)
	mov 0x08(%bp), %ax # (size)
	add %ax, %dx
	mov FSP_OFF_F_SIZE(%si), %cx # file_size

	# (file_size < total_size) ? {err}
	cmp %dx, %cx
	jb 8001f
	# }

	# { calc size
	xor %ax, %ax
	mov %ax, -0x0C(%bp) # (l.6: sec_size)

	mov 0x06(%bp), %ax # (idx)
	and $FS_MASK_OFF, %ax
	mov 0x08(%bp), %dx # (size)
	add %dx, %ax

	# (total_size < blk_size) ? {pass}
	cmp $FS_BLK_SIZE, %ax
	jl 1f

	sub $FS_BLK_SIZE, %ax
	mov %ax, -0x0C(%bp) # (l.6: sec_size)
	mov 0x08(%bp), %cx # (size)
	sub %ax, %cx
	mov %cx, -0x0A(%bp) # (l.5: fst_size)
	# }

1:
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	mov $FS_BLK_SIZE, %cx
	xor %dx, %dx
	div %cx

	mov %ax, -0x02(%bp) # (l.1: blk_idx)
	mov %dx, -0x04(%bp) # (l.2: idx_off)

	# (sec_size != 0) ? {frag} : {norm}
	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jnz 1f
	jmp 10f

1: # fragment
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	mov 0x08(%bp), %cx # (size)
	add %cx, %ax

	mov $FS_BLK_SIZE, %cx
	xor %dx, %dx
	div %cx

	mov %ax, -0x06(%bp) # (l.3: sec_blk_idx)
	mov %dx, -0x08(%bp) # (l.4: sec_size)
	jmp 10f

10:
	mov 0x04(%bp), %si # (fsp *src)
	mov -0x02(%bp), %ax # (l.1: blk_idx)
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK(%si), %ax # read blk

	push %ax
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>

	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)
	push %si
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x06(%bp), %ax # (idx)
	and $0x0FFF, %ax
	mov $fs_buf, %si
	add %ax, %si

	mov -0x0A(%bp), %cx # (l.5: fst_size)
	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jnz 1f
	mov 0x08(%bp), %cx # (size)

1:
	push %cx # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	push $fs_read_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jnz 20f
	jmp 90f

20:
	mov 0x04(%bp), %si # (fsp *src)
	mov -0x06(%bp), %ax # (l.3: sec_blk_idx)
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK(%si), %ax # read blk

	push %ax
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>

	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)
	push %si
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov $fs_buf, %si
	mov -0x08(%bp), %cx # (l.4: sec_size)
	mov $fs_read_buf, %di
	mov -0x0A(%bp), %ax # (l.5: fst_size
	add %ax, %di

	push %cx # (size)
	push %si # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
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
	push $emsg_fs_size
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b

# fs_write(
# fsp *src,
# ub16 idx,
# ub16 size
# )
# <req: fs_write_buf>
# <ro: (dpi bbm)>
# <rw: fs_buf>
fs_write:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	# { chk f_size
	mov 0x06(%bp), %ax # (idx)
	mov 0x08(%bp), %cx # (size)
	add %cx, %ax

	# (total_size > max_f_size) ? {err}
	cmp $IND_MAX_F_SIZE, %ax
	ja 8001f
	# }

	# { calc size
	xor %ax, %ax
	mov %ax, -0x0C(%bp) # (l.6: sec_size)

	mov 0x06(%bp), %ax # (idx)
	and $0x0FFF, %ax
	mov 0x08(%bp), %dx # (size)
	add %dx, %ax

	# (total_size < blk_size) ? {pass}
	cmp $FS_BLK_SIZE, %ax
	jb 1f

	sub $FS_BLK_SIZE, %ax
	mov %ax, -0x0C(%bp) # (l.6: sec_size)
	mov 0x08(%bp), %cx # (size)
	sub %ax, %cx
	mov %cx, -0x0A(%bp) # (l.5: fst_size)
	# }

1:
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	mov $FS_BLK_SIZE, %cx
	xor %dx, %dx
	div %cx

	mov %ax, -0x02(%bp) # (l.1: blk_idx)
	mov %dx, -0x04(%bp) # (l.2: idx_off)

	# (sec_size != 0) ? {frag}
	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jnz 1f

	# (blk_cnt >= calc_blk_cnt) ? {write} : {new_blk}
	mov -0x02(%bp), %ax # (l.1: blk_idx)
	mov %al, %dh
	inc %dh
	mov FSP_OFF_BLK_CNT(%si), %dl
	cmp %dh, %dl
	jae 50f
	jmp 10f

1: # fragment
	# { chk blk
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	mov 0x08(%bp), %cx # (size)
	add %cx, %ax

	mov $FS_BLK_SIZE, %cx
	xor %dx, %dx
	div %cx

	mov %ax, -0x06(%bp) # (l.3: sec_blk_idx)
	mov %dx, -0x08(%bp) # (l.4: sec_size)

	# (blk_cnt >= calc_blk_cnt) ? {frag_write} : {new_blk}
	mov %al, %dh
	inc %dh
	mov FSP_OFF_BLK_CNT(%si), %dl
	cmp %dh, %dl
	jae 50f
	jmp 10f
	# }

10: # new blk
	# { upd blk cnt
	mov 0x04(%bp), %si # (fsp *src)
	mov FSP_OFF_BLK_CNT(%si), %dl

	# (blk_cnt == blk_max) ? {err}
	cmp $IND_MAX_BLK_CNT, %dl
	je 8002f

	inc %dl
	mov %dl, FSP_OFF_BLK_CNT(%si)
	# }

	xor %dh, %dh
	dec %dx
	add %dx, %si
	add %dx, %si

	push %es # [s.0: it_seg]
	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push %bx # (off)
	push %es # (seg)
	call bm_alloc
	add $0x04, %sp
	# <ax = bit_num>

	push %ax # [s.f0: bit_num]
	push %ax # (bit_num)
	push %bx # (off)
	push %es # (seg)
	call bm_set
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	pop %ax # [s.f0: bit_num]

	# store blk num
	pop %es # [s.0: it_seg]
	mov %ax, FSP_OFF_BLK(%si)
	jmp 50f

	# (sec_size == 0) ? {norm} : {frag}
	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jz 50f
	jmp 60f

50: # write
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	mov 0x08(%bp), %cx # (size)
	add %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)
	mov -0x02(%bp), %ax # (l.1: blk_idx)
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK(%si), %ax # write blk

	push %ax
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>
	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)

	# upd ind
	push %si
	call fsp_write
	add $0x02, %sp

	push %si
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x06(%bp), %dx # (idx)
	and $0x0FFF, %dx
	mov $fs_buf, %di
	add %dx, %di

	# (sec_size != 0) ? {norm}
	mov -0x0A(%bp), %cx # (l.5: fst_size)
	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jnz 1f
	mov 0x08(%bp), %cx # (size)

1:
	push %cx # (size)
	push $fs_write_buf # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $FS_BLK_SIZE # (size)
	push $fs_buf # (s_off)
	push %ds # (s_seg)
	push %bx # (d_off)
	push %es # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x04(%bp), %si # (fsp *src)
	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp

	mov -0x0C(%bp), %ax # (l.6: sec_size)
	test %ax, %ax
	jnz 60f
	jmp 90f

60: # sec write
	mov 0x04(%bp), %si # (fsp *src)
	mov -0x06(%bp), %ax # (l.3: sec_blk_idx)
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK(%si), %ax # fst_blk

	push %ax
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>
	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)

	# upd ind
	push %si
	call fsp_write
	add $0x02, %sp

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov $fs_buf, %di
	mov $fs_write_buf, %si
	mov -0x0A(%bp), %ax # (l.5: fst_size)
	add %ax, %si

	push -0x0C(%bp) # (l.6: sec_size)
	push %si # (s_off)
	push %ds # (s_seg)
	push %di # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $FS_BLK_SIZE # (size)
	push $fs_buf # (s_off)
	push %ds # (s_seg)
	push %bx # (d_off)
	push %es # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x04(%bp), %si # (fsp *src)
	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp
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
	push $emsg_fs_size
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b

8002:
	push $emsg_fs_blk_cnt
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b

# fs_blk_to_lba(ub16 blk_num)
# <ret: ax = lba>
fs_blk_to_lba:
	push %bp
	mov %sp, %bp
	push %es
	push %bx

	mov 0x04(%bp), %ax # (blk_num)
	xor %dx, %dx
	mov $DISK_BLK_SECT_CNT, %cx
	mul %cx

	# get norm lba
	mov $(DISK_SB_MEM>>0x10), %cx
	mov %cx, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx
	mov %es:SB_OFF_NORM_LBA(%bx), %cx
	add %cx, %ax # <ret:lba>

	pop %bx
	pop %es
	pop %bp
	ret

# fs_del(
# fsp *src,
# ub16 idx,
# ub16 size
# )
fs_del:
	push %bp
	mov %sp, %bp
	sub $0x10, %sp
	push %es
	push %si
	push %di
	push %bx

	# (f_size - (idx + size) = shl_size)
	mov 0x04(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %cx
	mov 0x06(%bp), %dx # (idx)
	mov 0x08(%bp), %ax # (size)
	add %ax, %dx
	sub %dx, %cx
	mov %cx, -0x02(%bp) # (l.1: shl_size)

	# { dispatch
	mov 0x06(%bp), %dx # (idx)
	and $FS_MASK_OFF, %dx
	mov 0x08(%bp), %ax # (size)
	mov -0x02(%bp), %cx # (l.1: shl_size)
	add %ax, %dx
	add %cx, %dx

	# ((i+s+ss) < blk_size) ? {one}
	cmp $FS_BLK_SIZE, %dx
	jb 10f
	jmp 20f
	# }

10: # one
	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	and $FS_MASK_BLK, %ax
	shr $0x0C, %ax
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK(%si), %ax

	push %ax # (blk_num)
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>

	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)

	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x06(%bp), %ax # (idx)
	and $FS_MASK_OFF, %ax
	mov $fs_buf, %si
	add %ax, %si

	mov 0x06(%bp), %dx # (idx)
	mov 0x08(%bp), %cx # (size)
	mov %si, %di
	add %cx, %si

11: # shl
	# (size == 0) ? {end}
	test %cx, %cx
	jz 19f

	mov (%si), %al
	mov %al, (%di)

	inc %si
	inc %di
	dec %cx
	jmp 11b

19:
	mov 0x04(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %ax
	mov 0x08(%bp), %cx # (size)
	sub %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)

	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	push $FS_BLK_SIZE # (size)
	push $fs_buf # (s_off)
	push %ds # (s_seg)
	push %bx # (d_off)
	push %es # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x04(%bp), %si # (fsp *src)
	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp

	# { clr blk
	# (blk_size / f_size)
	mov FSP_OFF_F_SIZE(%si), %ax
	mov $FS_BLK_SIZE, %cx
	xor %dx, %dx
	div %cx
	# <ax = real_blk_cnt>

	# (remain != 0) ? {pass}
	test %dx, %dx
	jnz 1f
	dec %ax

1:
	xor %cx, %cx
	mov FSP_OFF_BLK_CNT(%si), %cl

	# (real_blk_cnt == blk_cnt) ? {done}
	cmp %cx, %ax
	je 90f
	dec %cx

	add %cx, %si
	add %cx, %si
	mov FSP_OFF_BLK(%si), %cx

	xor %ax, %ax
	mov %ax, FSP_OFF_BLK(%si)

	push %cx # [s.f0: blk_num]
	mov 0x04(%bp), %si
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp
	pop %cx # [s.f0: blk_num]

	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push %cx # (bit_num)
	push %bx # (off)
	push %es # (seg)
	call bm_clr
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	jmp 90f

20:
	mov $0x01, %ax
	mov %ax, -0x0C(%bp) # (l.6: fst)

	mov 0x06(%bp), %ax # (idx)
	and $FS_MASK_BLK, %ax
	shr $0x0C, %ax
	mov %ax, -0x04(%bp) # (l.2: blk_idx)

	mov 0x04(%bp), %si # (fsp *src)
	mov 0x06(%bp), %ax # (idx)
	and $FS_MASK_BLK, %ax
	mov FSP_OFF_F_SIZE(%si), %cx
	and $FS_MASK_BLK, %cx
	sub %ax, %cx
	mov %cx, -0x06(%bp) # (l.3: chk_end)

21:
	xor %ax, %ax
	push $FS_BLK_SIZE # (size)
	push %ax # (val)
	push $fs_tmp_buf # (d_off)
	push %ds # (d_seg)
	call mem_set
	add $0x0A, %sp

	# { read tmp
	# ((chk_end>>0x0C) == 0) ? {pass}
	mov -0x06(%bp), %ax # (l.3: chk_end)
	shr $0x0C, %ax
	test %ax, %ax
	jz 1f

	mov 0x04(%bp), %si # (fsp *src)
	mov -0x04(%bp), %ax # (l.2: blk_idx)
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK+0x02(%si), %ax

	push %ax # (blk_num)
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>

	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	# mem -> fs_tmp_buf
	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_tmp_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp
	# }

1:
	mov -0x04(%bp), %ax # (l.2: blk_idx)
	add %ax, %si
	add %ax, %si
	mov FSP_OFF_BLK(%si), %ax

	push %ax # (blk_num)
	call fs_blk_to_lba
	add $0x02, %sp
	# <ax = lba>

	mov 0x04(%bp), %si # (fsp *src)
	mov %ax, FSP_OFF_DISK_LBA(%si)

	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp

	push %si # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	push $FS_BLK_SIZE # (size)
	push %bx # (s_off)
	push %es # (s_seg)
	push $fs_buf # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	# { init shl
	mov $fs_buf, %si
	mov %si, %di
	mov 0x08(%bp), %ax # (size)
	add %ax, %si
	xor %ax, %ax

	# (!fst) ? {pass}
	mov -0x0C(%bp), %dx # (l.6: fst)
	test %dx, %dx
	jz 1f

	mov 0x06(%bp), %ax # (idx)
	and $FS_MASK_OFF, %ax
	mov $fs_buf, %si
	add %ax, %si
	mov %si, %di
	mov 0x08(%bp), %ax # (size)
	add %ax, %si

	xor %ax, %ax
	mov %ax, -0x0C(%bp) # (l.6: fst)
	mov 0x06(%bp), %ax # (idx)

1:
	mov $FS_BLK_SIZE, %cx
	sub %ax, %cx
	mov %cx, -0x08(%bp) # (l.4: blk_end)
	mov 0x08(%bp), %ax # (size)
	sub %ax, %cx
	mov %cx, -0x0A(%bp) # (l.5: blk_end_tmp)

	mov -0x08(%bp), %cx # (l.4: blk_end)
	mov -0x06(%bp), %ax # (l.3: chk_end)
	shr $0x0C, %ax
	test %ax, %ax
	jz 22f
	mov -0x0A(%bp), %cx # (l.5: blk_end_tmp)
	and $FS_MASK_OFF, %cx
	jmp 22f
	# }

22: # shl
	# (cnt == 0) ? {next}
	test %cx, %cx
	jz 23f

	mov (%si), %al
	mov %al, (%di)

	inc %si
	inc %di
	dec %cx
	jmp 22b

23:
	# (end == 0) ? {end}
	mov -0x06(%bp), %ax # (l.3: chk_end)
	shr $0x0C, %ax
	test %ax, %ax
	jz 29f

	mov $fs_tmp_buf, %si
	mov -0x08(%bp), %cx # (l.4: blk_end)
	mov -0x0A(%bp), %ax # (l.5: blk_end_tmp)
	sub %ax, %cx
	jmp 24f

24: # shl
	# (cnt == 0) ? {next}
	test %cx, %cx
	jz 29f

	mov (%si), %al
	mov %al, (%di)

	inc %si
	inc %di
	dec %cx
	jmp 24b

29:
	push $FS_BLK_SIZE # (size)
	push $fs_buf # (s_off)
	push %ds # (s_seg)
	push %bx # (d_off)
	push %es # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	mov 0x04(%bp), %si # (fsp *src)
	push %si # (fsp &src)
	call disk_write_fsp
	add $0x02, %sp

	# { upd and chk
	mov -0x06(%bp), %ax # (l.3: chk_end)
	sub $FS_BLK_SIZE, %ax

	# (chk_end < 0) ? {done}
	cmp $0x00, %ax
	jl 1f
	mov %ax, -0x06(%bp) # (l.3: chk_end)

	mov -0x02(%bp), %ax # (l.1: shl_size)
	sub $FS_BLK_SIZE, %ax
	mov %ax, -0x02(%bp) # (l.1: shl_size)
	mov -0x04(%bp), %ax # (l.2: blk_idx)
	inc %ax
	mov %ax, -0x04(%bp) # (l.2: blk_idx)
	jmp 21b

1:
	mov 0x04(%bp), %si # (fsp *src)
	mov FSP_OFF_F_SIZE(%si), %ax
	mov 0x08(%bp), %cx # (size)
	sub %cx, %ax
	mov %ax, FSP_OFF_F_SIZE(%si)

	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp
	# }

	# { clr blk
	# (blk_size / f_size)
	mov FSP_OFF_F_SIZE(%si), %ax
	mov $FS_BLK_SIZE, %cx
	xor %dx, %dx
	div %cx
	# <ax = real_blk_cnt>

	# (remain != 0) ? {pass}
	test %dx, %dx
	jnz 1f
	dec %ax

1:
	xor %cx, %cx
	mov FSP_OFF_BLK_CNT(%si), %cl

	# (real_blk_cnt == blk_cnt) ? {done}
	cmp %cx, %ax
	je 90f
	dec %cx

	add %cx, %si
	add %cx, %si
	mov FSP_OFF_BLK(%si), %cx

	xor %ax, %ax
	mov %ax, FSP_OFF_BLK(%si)

	push %cx # [s.f0: blk_num]
	mov 0x04(%bp), %si
	push %si # (fsp &src)
	call fsp_write
	add $0x02, %sp
	pop %cx # [s.f0: blk_num]

	mov $(DISK_BBM_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_BBM_MEM&0xFFFF), %bx

	push %cx # (bit_num)
	push %bx # (off)
	push %es # (seg)
	call bm_clr
	add $0x06, %sp

	push $dpi+DPI_OFF_BBM
	call disk_write_dpi
	add $0x02, %sp
	jmp 90f
	# }

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
	push $emsg_fs_size
	call vga_outs
	add $0x02, %sp

	NEWLINE
	jmp 80b

.section .data
.global fs_buf
.global fs_tmp_buf
.global fs_read_buf
.global fs_write_buf

fs_buf: .zero FS_BLK_SIZE
fs_tmp_buf: .zero FS_BLK_SIZE
fs_read_buf: .zero FS_BLK_SIZE
fs_write_buf: .zero FS_BLK_SIZE
