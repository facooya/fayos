# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Command test - temporary debug and test runtime

.include "drv/disk.s"
.include "fs/ind.s"
.include "fs/dentry.s"
.include "fs/sb.s"
.section .data
.str: .asciz "Hello world Hello World 2 Hello world 3 Hello world 4 Hello world 5 Hello world 6 Hello world 7\r\n"

.section .text
.code16
.global cmd_test

# cmd_test()
cmd_test:
	push %es
	push %si
	push %bx

	#mov $de_hist+0x02, %si

	#push %si
	#call fs_open
	#add $0x02, %sp

	push $root_inum
	call ind_get_ptr
	add $0x02, %sp
	mov %dx, %es
	mov %ax, %bx
	mov %es:IND_OFF_FILE_SIZE(%bx), %dx
	push %dx

	# {{{ TEST: root
	# TODO: blk hi
	mov IND_OFF_BLK_0(%bx), %ax
	xor %dx, %dx
	mov $0x08, %cx
	mul %cx
	mov %ax, %cx

	# TODO: lba overflow
	# get norm lba
	mov $(DISK_SB_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_SB_MEM&0xFFFF), %bx
	mov %es:SB_OFF_NORM_LBA(%bx), %ax
	add %ax, %cx

	push $DISK_BLK_SECT_CNT # sect_cnt
	push %cx # lba_lo
	xor %ax, %ax
	push %ax # lba_hi
	push $(DISK_ROOT_MEM&0xFFFF) # off
	push $(DISK_ROOT_MEM>>0x10) # seg
	call ata_read_sect
	add $0x0A, %sp
	mov $(DISK_ROOT_MEM>>0x10), %ax
	mov %ax, %es
	mov $(DISK_ROOT_MEM&0xFFFF), %bx
	# }}}

	pop %dx

.run__lp:
	# (inum == 0) ? {chk}
	mov %es:DE_INUM_OFF(%bx), %ax
	test %ax, %ax
	or %es:DE_INUM_OFF+0x02(%bx), %ax
	jz .run__chk

	mov %bx, %si
	add $DE_NAME_OFF, %si

	xor %cx, %cx
	mov %es:DE_NAME_LEN_OFF(%bx), %cl

.run__name_lp:
	test %cx, %cx
	jz .run__name_end

	mov %es:(%si), %al
	call putc

	inc %si
	dec %cx
	jmp .run__name_lp

.run__name_end:
	call putsp
	call putsp

.run__chk:
	mov %es:DE_REC_LEN_OFF(%bx), %ax
	add %ax, %bx
	sub %ax, %dx

	# (file_size <= 0) ? {done} : {lp}
	cmp $0x00, %dx
	jle .done
	jmp .run__lp

.done:
	call putnl
	xor %ax, %ax

	pop %bx
	pop %si
	pop %es
	ret
