# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.section .text
.code16
.global isr_ata

# irq 0x0E
isr_ata:
	push %bx
	push %ax
	push %cx
	push %dx

	mov $ata_stat, %bx

	# int clr
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	# TODO: err, df

	mov (init_flag), %ax
	test %ax, %ax
	jnz .done

	mov ATA_STAT_CMD(%bx), %al
	cmp $ATA_READ, %al
	je .read
	cmp $ATA_WRITE, %al
	je .write
	jmp .done

.read:
	push %es # [s.0:seg]
	push %di # [s.1:off]
	mov ATA_STAT_SEG(%bx), %ax
	mov %ax, %es
	mov ATA_STAT_OFF(%bx), %di
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep insw

	# delay 400ns
	mov $ATA_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	mov %di, ATA_STAT_OFF(%bx)
	pop %di # [s.1:off]
	pop %es # [s.0:seg]

	mov ATA_STAT_CNT(%bx), %al
	dec %al
	mov %al, ATA_STAT_CNT(%bx)
	jmp .done

.write:
	mov ATA_STAT_CNT(%bx), %al
	dec %al
	mov %al, ATA_STAT_CNT(%bx)
	test %al, %al
	jz .done

.write__next:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_DRQ, %al
	jz .write__next

	push %si # [s.0:off]
	push %ds # [s.1:seg]
	mov ATA_STAT_OFF(%bx), %si
	mov ATA_STAT_SEG(%bx), %ax
	mov %ax, %ds
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns
	mov $ATA_ALT_STAT, %dx
	in %dx, %al
	in %dx, %al
	in %dx, %al
	in %dx, %al

	pop %ds # [s.1:seg]
	mov %si, ATA_STAT_OFF(%bx)
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
