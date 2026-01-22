# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "chr.inc"
.include "fs/fs.inc"
.include "fs/de.inc"
.section .text
.code16
.global exec_cmd

# [public] exec_cmd()
# <req> cmd_map, cl_sbuf, redir_hsbuf
# <mod> write_sbuf
exec_cmd:
	push %si
	push %di
	push %bx

	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	# { args_proc
	call args_proc
	# <ax = {true:0, exit:1}>
	cmp $0x01, %ax
	je 90f
	cmp $0x02, %ax
	je 20f
	# }
	jmp 10f

# si:bx = (argv[0]) chr:size
# di:cx = (map) chr:size
10:
	# { size
	mov $cl_sbuf, %si
	add $0x02, %si # *buf_data

	push %si
	push %ds
	call mem_size
	add $0x04, %sp

	mov %ax, %bx # cmd_size
	# }

	mov $cmd_map, %di
	add $0x02, %di # map_chr

1:
	# {{{ len
	push %di
	push %ds
	call mem_size
	add $0x04, %sp

	mov %ax, %cx # map_chr_size
	# }}}

	# (map_chr_size == cmd_size) ? {chk}
	cmp %bx, %cx
	je 3f

2:
	add $0x03, %cx # add null+addr_size
	add %cx, %di # *map_chr
	mov -0x02(%di), %ax # map_addr

	# (map_addr == null) ? {err} ? {lp}
	test %ax, %ax
	jz 801f # cmd not found
	jmp 1b

3:
	# { cmp
	push %cx # [s.f1:map_chr_size]

	push %cx
	push %si
	push %ds
	push %di
	push %ds
	call mem_cmp
	add $0x0A, %sp

	pop %cx # [s.f1:map_chr_size]
	# }

	# (mem_cmp() == true) ? {end} : {step}
	test %ax, %ax
	jz 9f
	jmp 2b

9:
	mov -0x02(%di), %bx # map_addr
	call *%bx
	test %ax, %ax
	jnz 90f

	# (redir.hdr != 0) ? {redir}
	mov $redir_hsbuf, %si
	mov (%si), %cx
	test %cx, %cx
	jnz 20f

	# print
	mov $write_sbuf, %si
	mov (%si), %cx # buf.len
	add $0x02, %si # skip len

	push %si
	call vga_outs
	add $0x02, %sp
	jmp 90f

20:
	call _exec_redir
	jmp 90f

90:
	# zero
	xor %ax, %ax
	mov (write_sbuf), %cx
	add $0x02, %cx
	push %cx # (size)
	push %ax # (value)
	push $write_sbuf # (off)
	push %ds # (seg)
	call mem_set
	add $0x08, %sp

	pop %bx
	pop %di
	pop %si
	ret

801:
	push $emsg_cmd_not
	jmp 890f

890:
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	jmp 90b

# [private] _exec_redir()
# <req> redir_hsbuf, write_sbuf
# <mod> fsp
_exec_redir:
	push %es
	push %si
	push %di
	push %bx

	# init
	mov $redir_hsbuf, %si
	mov (%si), %ax # type:len
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl # buf.len

	# (redir_type == write) ? {write}
	cmp $0x01, %ah # type
	je 10f
	# (redir_type == append) ? {append} : {err}
	cmp $0x02, %ah
	je 10f
	jmp 802f # redir type

10:
	# { path
	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	# (path_parse() == exit) ? {err}
	cmp $0x01, %ax
	je 801f
	# (path_parse() != neq_last) ? {skip}
	cmp $0x02, %ax
	jne 11f

	push $F_TYPE_FILE # (f_type)
	push %si # (&path)
	call fs_add
	add $0x04, %sp

	# upd
	push %si # (&path)
	call path_parse
	add $0x02, %sp
	# <mod: (fsp &dir, &base)>
	# <ax = {done:0, exit:1, neq_last:2}>

	#(path_parse() != done) ? {err}
	test %ax, %ax
	jnz 801f
	# }

11:
	# (f_type != file) ? {err}
	mov $fsp+FSP_OFF_BASE, %si
	mov FSP_OFF_F_TYPE(%si), %ax
	cmp $F_TYPE_FILE, %ax
	jne 803f # file type

	push $FSP_SIZE # (size)
	push $fsp+FSP_OFF_BASE # (s_off)
	push %ds # (s_seg)
	push $fsp+FSP_OFF_TMP # (d_off)
	push %ds # (d_seg)
	call mem_cpy
	add $0x0A, %sp

	push $fsp+FSP_OFF_TMP # (fsp &src)
	call disk_read_fsp
	add $0x02, %sp
	# <dx:ax = seg:off>
	mov %dx, %es
	mov %ax, %bx

	mov $fsp+FSP_OFF_TMP, %si
	mov FSP_OFF_F_SIZE(%si), %cx # f_size

	add %cx, %bx
	mov %cx, %dx # f_size
	mov (redir_hsbuf), %ax
	cmp $0x02, %ah
	je 21f # append
	sub %cx, %bx

	xor %ax, %ax

20: # run
1: # clear
	# (file_size <= 0) ? {end}
	cmp $0x00, %cx
	jle 9f

	mov %ax, %es:(%bx)

	add $0x02, %bx
	sub $0x02, %cx
	jmp 1b

9:
	mov FSP_OFF_DISK_MEM(%si), %bx
	xor %dx, %dx # f_size

21:
	mov $write_sbuf, %si
	mov (%si), %cx # buf.size
	add $0x02, %si # skip size

1:
	mov (%si), %al

	# (size == 0) ? {end}
	test %cx, %cx
	jz 9f

	mov %al, %es:(%bx)

	inc %si # chr
	inc %bx # mem
	inc %dx # size
	dec %cx # buf.size
	jmp 1b

9:
	push %dx # [s.f0:f_size]
	push $fsp+FSP_OFF_TMP
	call disk_write_fsp
	add $0x02, %sp
	pop %dx # [s.f0:f_size]

	mov $fsp+FSP_OFF_TMP, %si
	mov %dx, FSP_OFF_F_SIZE(%si)
	push $fsp+FSP_OFF_TMP # (fsp &src)
	call fsp_write
	add $0x02, %sp
	jmp 99f

80:
	mov $0x01, %ax
	jmp 99f

99:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

801: # path inv
	push $emsg_inv_path
	jmp 890f

802: # redir type
	push $emsg_redir_type
	jmp 890f

803: # file type
	push $emsg_file_type
	jmp 890f

890:
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	jmp 80b
