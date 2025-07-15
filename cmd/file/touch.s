# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command touch - create file

.include "fayfs/de.s"
.section .text
.code16
.global cmd_touch

# cmd_touch()
cmd_touch:
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
	# {{{ add inode
	#mov $0x80, %ch
	#mov $0x01, %cl
	#push %cx
	#mov (next_i_blk), %ax
	#push %ax
	#mov (next_i_blk+0x02), %ax
	#push %ax
	#mov (next_i_num), %ax
	#push %ax
	#mov (next_i_num+0x02), %ax
	#push %ax
	#call add_inode
	#add $0x0A, %sp
	# }}}

	# {{{ add dentry
	mov $args, %si
	mov 0x06(%si), %ax
	mov $raw_buf, %si
	add $0x02, %si
	add %ax, %si
	push %si
	call strlen
	add $0x02, %sp
	# ax = len

	mov $0x80, %ch # (info) file_type
	mov %al, %cl # (info) name_len
	push %si # name
	push %cx # info
	mov (next_i_num), %ax
	push %ax
	mov (next_i_num+0x02), %ax
	push %ax
	mov (inum), %ax
	push %ax
	mov (inum+0x02), %ax
	push %ax
	call add_dentry
	add $0x0C, %sp
	# }}}

	# update sb
	#mov (next_i_num), %ax
	#add $0x01, %ax
	#mov %ax, (next_i_num)
	#mov (next_i_blk), %ax
	#add $0x01, %ax
	#mov %ax, (next_i_blk)
	#call write_super

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
