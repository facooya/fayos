# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command change directory

.include "chr.s"
.include "fayfs/dentry.s"
.include "fayfs/inode.s"
.section .text
.code16
.global cmd_cd

# cmd_cd()
cmd_cd:
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

	# (proc_paths() != done) ? {err}
	test %cx, %cx
	jnz .err_inv_path

	mov %ax, %bx
	mov %dx, %es
	# }}}
	call build_ps1_path
	jmp .run

.path_pass:
	# {{{ lookup dentry
	xor %ax, %ax
	push %si
	push %ax
	call strlen
	add $0x04, %sp

	push %ax # [s.0:strlen]
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
	pop %cx # [s.0:strlen]

	push %cx # [s.0:strlen]
	push %si # src_name
	push %cx # src_name_len
	mov $inode, %si
	mov I_FILE_SIZE_OFF(%si), %ax
	push %ax
	push %bx
	push %es
	call lookup_dentry
	add $0x0A, %sp
	pop %cx # [s.0:strlen]

	# (lookup_dentry() == no_match)
	# ? {err} : off+=ax;{run}
	cmp $0x01, %ax
	je .err_dir_no
	add %ax, %bx
	# }}}

	# {{{ add ps1 path
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	# (arg == dots) ? {sub}
	mov (%si), %ax
	cmp $0x2E2E, %ax
	je .run__sub

	# (arg == dot) ? {pass}
	cmp $0x002E, %ax
	je .run__pass

	push %si
	xor %ax, %ax
	push %ax
	call strlen
	add $0x04, %sp

	push %ax
	push %si
	xor %ax, %ax
	push %ax
	call add_ps1_path
	add $0x06, %sp
	# }}}

	jmp .run

# {TASK}
.run:
	# (file_type != dir) ? {err}
	mov %es:DE_FILE_TYPE_OFF(%bx), %al
	cmp $0x40, %al
	jne .err_dir_type

	# {{{ prompt
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]
	mov (%si), %ax
	cmp $0x2E2E, %ax
	je .run__sub

	cmp $0x002E, %ax
	je .run__pass
	jmp .run__ps1

.run__sub:
	call sub_ps1_path
	call build_ps1
	jmp .run__pass

.run__ps1:
	call build_ps1

.run__pass:
	# }}}

	# get dest inode num
	mov %es:DE_INUM_OFF(%bx), %ax
	mov %ax, (inum)
	mov %es:DE_INUM_OFF+0x02(%bx), %ax
	mov %ax, (inum+0x02)

	# get i blk
	push $inode
	push $inum
	call read_inode
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
.err_inv_path:
	push $emsg_inv_path
	jmp .err_hdl

.err_dir_no:
	push $emsg_dir_no
	jmp .err_hdl

.err_dir_type:
	push $emsg_dir_type
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
