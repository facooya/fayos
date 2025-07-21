# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Disk read/write

.section .text
.code16
.global read_disk
.global write_disk

# read_disk(&dap)
# <ret> ax = offset
# <ret> dx = segment
read_disk:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si
	call _sys_read_disk
	jc .err_disk_io

	jmp .done

# write_disk(&dap)
write_disk:
	push %bp
	mov %sp, %bp
	push %si

	mov 0x04(%bp), %si
	call _sys_write_disk
	jc .err_disk_io

	jmp .done

# {DONE}
.exit:
	mov $0x01, %ax
	jmp .epil

.done:
	mov 0x04(%si), %ax
	mov 0x06(%si), %dx
	jmp .epil

.epil:
	pop %si
	pop %bp
	ret

# {ERR}
.err_disk_io:
	push $emsg_disk_io
	call outs
	add $0x02, %sp
	call outnl
	jmp .exit
