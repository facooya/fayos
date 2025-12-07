# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.section .text
.code16
.global isr_ata

# irq 0x0E
# <mod> ata_buf
isr_ata:
	push %bx
	push %ax
	push %cx
	push %dx

	mov $ata_buf, %bx

	# int clr
	mov $ATA_PORT_STAT, %dx
	in %dx, %al
	# TODO: err, df

	mov (init_flag), %ax
	test %ax, %ax
	jnz .done

	mov ATA_BUF_CMD(%bx), %al
	cmp $ATA_CMD_READ, %al
	je .read
	cmp $ATA_CMD_WRITE, %al
	je .write
	jmp .done

.read:
	push %es # [s.0:seg]
	push %di # [s.1:off]
	mov ATA_BUF_SEG(%bx), %ax
	mov %ax, %es
	mov ATA_BUF_OFF(%bx), %di
	mov $ATA_PORT_DATA, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep insw

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	mov %di, ATA_BUF_OFF(%bx)
	pop %di # [s.1:off]
	pop %es # [s.0:seg]

	mov ATA_BUF_CNT(%bx), %al
	dec %al
	mov %al, ATA_BUF_CNT(%bx)
	jmp .done

.write:
	mov ATA_BUF_CNT(%bx), %al
	dec %al
	mov %al, ATA_BUF_CNT(%bx)
	test %al, %al
	jz .done

.write__wait:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz .write__wait

	push %si # [s.0:off]
	push %ds # [s.1:seg]
	mov ATA_BUF_OFF(%bx), %si
	mov ATA_BUF_SEG(%bx), %ax
	mov %ax, %ds
	mov $ATA_PORT_DATA, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %ds # [s.1:seg]
	mov %si, ATA_BUF_OFF(%bx)
	pop %si # [s.0:off]
	jmp .done

.done:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %dx
	pop %cx
	pop %ax
	pop %bx
	iret
