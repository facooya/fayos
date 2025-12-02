# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ata.s"
.section .data
.global ata_stat
.global ata_cnt
.global ata_seg
.global ata_off
ata_stat: .byte 0x00
ata_cnt: .word 0x00
ata_seg: .word 0x00
ata_off: .word 0x00
.cnt: .word 0x00

.section .text
.code16
.global irq_ata

# irq 0x0E
irq_ata:
	push %ax
	push %cx
	push %dx

	mov $ATA_STAT_REG, %dx
	in %dx, %al

	mov (init_flag), %ax
	test %ax, %ax
	jnz .done

	mov (ata_stat), %al
	cmp $ATA_READ, %al
	je .read
	cmp $ATA_WRITE, %al
	je .write
	jmp .done

.read:
	push %es
	push %di
	mov (ata_seg), %ax
	mov %ax, %es
	mov (ata_off), %di
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep insw
	mov %di, (ata_off)
	pop %di
	pop %es

	mov (ata_cnt), %ax
	dec %ax
	mov %ax, (ata_cnt)

	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_DRQ, %al
	jnz .read
	jmp .done

.write:
	mov (ata_cnt), %ax
	dec %ax
	mov %ax, (ata_cnt)
	test %ax, %ax
	jz .done

.write__next:
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	test $ATA_DRQ, %al
	jz .write__next

	push %si
	push %ds
	mov (ata_off), %si
	mov (ata_seg), %ax
	mov %ax, %ds
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw
	pop %ds
	mov %si, (ata_off)
	pop %si

	jmp .epil

.write__end:
	mov $ATA_STAT_REG, %dx
	in %dx, %al

	xor %ah, %ah
	push %ax
	call dbg_reg
	add $0x02, %sp

	test $ATA_DRQ, %al
	jnz .write
	jmp .done

.done:
	mov $ATA_STAT_REG, %dx
	in %dx, %al

.epil:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $0x80
	out %al, $PIC1_PORT_CMD

	pop %dx
	pop %cx
	pop %ax
	iret
