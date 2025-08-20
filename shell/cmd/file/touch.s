# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command touch - create file

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
cmd_touch:
	push %es
	push %si
	push %di
	push %bx

	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	# (path_buf[0] != slash) ? {pass}
	mov (%si), %al
	cmp $CHR_SL, %al
	jne .path_pass

	# {{{ proc paths
	push %si
	call proc_paths
	add $0x02, %sp

	# (proc_path() == 1) ? {err}
	cmp $0x01, %cx
	je .err_inv_path

	# (proc_path() != 2) ? {err}
	cmp $0x02, %cx
	jne .err_name_dup

	mov %ax, %bx
	mov %dx, %es
	# }}}

	# <ret> tmp_inum
	call add_inode

	# {{{ add dentry
	mov $paths, %si
	mov (%si), %cx # pathc
	add $0x02, %si
	add %cx, %si
	add %cx, %si
	sub $0x02, %si # pathv[last]

	mov (%si), %ax
	mov $path_buf, %si
	add $0x02, %si
	add %ax, %si

	# {{ len
	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp
	# ax = len
	# }}

	mov $0x80, %ch # (info) file_type
	mov %al, %cl # (info) name_len
	push %si # name
	push %cx # info
	push $path_inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax
	# }}}

	push $inode
	push $path_inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $path_inum
	call update_inode
	add $0x04, %sp
	jmp .done

.path_pass:
	# {{ len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call strlen
	add $0x04, %sp

	mov %ax, %cx
	pop %es
	# }}

	push %cx
	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	push $inode
	call set_dap_blk_lba
	add $0x02, %sp

	push $dap
	call read_disk
	add $0x02, %sp
	mov %ax, %bx
	mov %dx, %es
	pop %cx

.path:
	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp

	# {err} (lookup_dentry() != no_match)
	cmp $0x01, %ax
	jnz .err_name_dup

	# {task}
	jmp .run
	# }}}

# {TASK}
.run:
	call add_inode

	# {{{ add dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si

	# {{ len
	push %es
	xor %ax, %ax
	mov %ax, %es

	push %si
	push %es
	call strlen
	add $0x04, %sp
	pop %es
	# ax = len
	# }}

	mov $0x80, %ch # (info) file_type
	mov %al, %cl # (info) name_len
	push %si # name
	push %cx # info
	push $inum
	push $tmp_inum
	call add_dentry
	add $0x08, %sp
	push %ax
	# }}}

	push $inode
	push $inum
	call read_inode
	add $0x04, %sp

	pop %ax
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %cx
	add %cx, %ax
	mov %ax, I_FILE_SIZE_OFF(%si)

	push $inode
	push $inum
	call update_inode
	add $0x04, %sp

	# {end.done}
	jmp .done

# {DONE}
.done:
	xor %ax, %ax
	jmp .epil

.exit:
	mov $0x01, %ax
	jmp .epil

.epil:
	pop %bx
	pop %di
	pop %si
	pop %es
	ret

# {ERR}
.err_name_dup:
	push $emsg_name_dup
	jmp .err_hdl

.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
