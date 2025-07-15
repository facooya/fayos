# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command make directory

.include "fayfs/de.s"
.section .text
.code16
.global cmd_mkdir

# cmd_mkdir()
cmd_mkdir:
	push %si
	push %di
	push %bx

	# {{{ lookup dentry
	mov $args, %si
	mov 0x06(%si), %ax # argv[1]
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si # raw_buf[argv[1]]

	push %si # arg
	call strlen
	add $0x02, %sp
	mov %ax, %cx

	push %si # src_name
	push %cx # src_name_len
	mov (inum), %ax
	push %ax # inum_lo
	mov (inum+0x02), %ax
	push %ax # inum_hi
	call lookup_dentry
	add $0x08, %sp

	# {err} (lookup_dentry != 0)
	test %ax, %ax
	jnz .err_name_dup

	# {task}
	jmp .run
	# }}}

# {TASK}
.run:
	# {{{ add_inode
	mov $0x40, %ch
	mov $0x01, %cl
	push %cx

	# ((( alloc blknum bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	xor %ax, %ax
	push %ax
	# )))
	# ((( alloc inum bit
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp
	push %ax
	xor %ax, %ax
	push %ax
	# )))

	call add_inode
	add $0x0A, %sp
	# }}}

	# {{{ set blknum bit
	push $dap_bb
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_bb
	call write_disk
	add $0x02, %sp
	# }}}

	# {init} for add_dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si

	push %si
	call strlen
	add $0x02, %sp
	# ax = len

	# add_dentry
	mov %al, %cl
	mov $0x40, %ch
	push %si
	push %cx

	# ((( alloc inum
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	xor %ax, %ax
	push %ax
	# )))

	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	# }}}

	# {{{ add child directory
	# add dentry dot
	mov $de_dots, %si
	mov 0x02(%si), %cx
	push %si
	push %cx

	# ((( alloc inum
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	xor %ax, %ax
	push %ax
	# )))

	# ((( alloc inum
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	xor %ax, %ax
	push %ax
	# )))

	call add_dentry
	add $0x0C, %sp

	# add dentry dotdot
	mov $de_dots, %si
	add $0x04, %si
	mov 0x02(%si), %cx
	push %si
	push %cx
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax

	# ((( alloc inum
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	xor %ax, %ax
	push %ax
	# )))

	call add_dentry
	add $0x0C, %sp
	# }}}

	# {{{ set inum bit
	push $dap_ib
	call read_disk
	add $0x02, %sp
	mov %ax, %bx

	push %bx
	call alloc_bit
	add $0x02, %sp

	push %ax
	push %bx
	call set_bit
	add $0x04, %sp

	push $dap_ib
	call write_disk
	add $0x02, %sp
	# }}}

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
	ret

# {ERR}
.err_name_dup:
	push $emsg_name_dup
	jmp .err_hdl

.err_hdl:
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
