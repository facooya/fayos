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
ata_cnt: .word 0x00
ata_seg: .word 0x00
ata_off: .word 0x00
ata_stat: .byte 0x00

.section .text
.code16
.global irq_ata

# irq 0x0E
irq_ata:
	push %ax
	push %cx
	push %dx

	# int clr
	mov $ATA_STAT_REG, %dx
	in %dx, %al
	# TODO: err, df

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
	push %es # [s.0:seg]
	push %di # [s.1:off]
	mov (ata_seg), %ax
	mov %ax, %es
	mov (ata_off), %di
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep insw

	# delay 400ns
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT

	mov %di, (ata_off)
	pop %di # [s.1:off]
	pop %es # [s.0:seg]

	mov (ata_cnt), %ax
	dec %ax
	mov %ax, (ata_cnt)
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
	test $ATA_BSY, %al
	jnz .write__next
	test $ATA_DRQ, %al
	jz .write__next

	push %si # [s.0:off]
	push %ds # [s.1:seg]
	mov (ata_off), %si
	mov (ata_seg), %ax
	mov %ax, %ds
	mov $ATA_DATA_REG, %dx
	mov $ATA_SECT_SIZE_WORD, %cx
	rep outsw

	# delay 400ns
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT
	out %al, $IO_WAIT

	pop %ds # [s.1:seg]
	mov %si, (ata_off)
	pop %si # [s.0:off]
	jmp .done

.done:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %dx
	pop %cx
	pop %ax
	iret
