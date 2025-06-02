# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Execute redirection

.include "fayfs/de.s"
.section .text
.code16
.global exec_redir

# exec_redir()
exec_redir:
	# prol
	push %si
	push %di
	push %bx

	# init
	mov $redir_buf, %si
	mov (%si), %ax # type:len
	add $0x02, %si

	xor %cx, %cx
	mov %al, %cl # len

	# {task} (redir_type == 1)
	cmp $0x01, %ah # type
	je .type__write

	# {end.err}
	jmp .hdl_redir_type_err

# {TASK}
.type__write:
	# read_inode(i_num_hi, i_num_lo)
	# <ret> i_file_size
	# <ret> i_blk
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# read block
	call set_blk_lba
	call read_block
	mov $0x8000, %bx

	call dt_a
	call dt_b
	call dt_c

	# DEBUG CONTINUE!!!!!
	# {task}
	jmp .match

# {TASK}
.match:
# <PRE>
# (*si == fst_chr)
.match__lp:
	# strlen(src)
	# <ret> ax = len
	push %si
	call strlen
	add $0x02, %sp

	# {init} de_name_len
	xor %cx, %cx
	mov DE_NAME_LEN_OFF(%bx), %cl

	# {end.err} (de_name_len == null)
	test %cx, %cx
	jz .hdl_no_file_err

	# {chk} (redir_name_len == de_name_len)
	cmp %cx, %ax
	je .match__chk
	jmp .match__lp

.match__chk:
	mov %bx, %di # de
	add $DE_NAME_OFF, %di # de_name

	# strncmp(src, dst, n)
	# <ret> ax = true || false
	push %cx # redir_name_len
	push %di # de_name
	push %si # redir_name
	call strncmp
	add $0x06, %sp

	# {end} (strncmp == true)
	test %ax, %ax
	jz .match__end

	# {lp.step} mem_ptr
	mov DE_REC_LEN_OFF(%bx), %cx
	add %cx, %bx

	# {lp}
	jmp .match__lp

.match__end:
	# {end.err} (file_type != file)
	mov DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x80, %al
	jnz .hdl_not_file_err

	# {task}
	jmp .file

# {TASK}
.file:
	# get dst i num
	mov DE_I_NUM_LO_OFF(%bx), %ax
	mov %ax, (i_num)
	mov DE_I_NUM_HI_OFF(%bx), %ax
	mov %ax, (i_num+0x02)

	# read i node
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call read_inode
	add $0x04, %sp

	# init mem
	mov $0x8000, %bx
	xor %dx, %dx # file_size

	# HACK!!! no opt only, get argc == 0 end
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si

.file__write_lp:
	mov (%si), %al

	# {chk} (chr == null)
	test %al, %al
	jz .file__write_chk

	mov %al, (%bx)

	# {lp}
	add $0x01, %si # chr
	add $0x01, %bx # mem
	add $0x01, %dx # size
	jmp .file__write_lp

.file__write_chk:
	# FIXME: argc--; == 0; end;
	jmp .file__write_end

.file__write_end:
	call set_blk_lba
	call write_block

.file__end:
	# update_i_file_size
	# (
	# i_num_hi
	# i_num_lo
	# file_size
	# )
	push %dx # size
	mov (i_num), %ax
	push %ax
	mov (i_num+0x02), %ax
	push %ax
	call update_i_file_size
	add $0x06, %sp
	xor %ax, %ax
	jmp .done

.exit:
	mov $0x01, %ax
	jmp .done

.done:
	pop %bx
	pop %di
	pop %si
	ret

# {ERR}
.hdl_redir_type_err:
	call outnl
	push $redir_type_err_msg
	jmp .hdl_err

.hdl_no_file_err:
	call outnl
	push $no_file_err_msg
	jmp .hdl_err

.hdl_not_file_err:
	call outnl
	push $not_file_err_msg
	jmp .hdl_err

.hdl_err:
	call puts
	add $0x02, %sp
	call outnl
	jmp .exit
