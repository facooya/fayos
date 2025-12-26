# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.include "int.s"
.include "drv/ps2.s"
.include "drv/rtc.s"
.include "drv/ata.s"
.section .text
.code16
.global isr_ps2
.global isr_rtc
.global isr_ata

# irq 0x01
isr_ps2:
	push %ax

	# (init_flag != 0) ? {skip}
	mov (init_flag), %ax
	test %ax, %ax
	jnz 4f

	in $PS2_PORT_DATA, %al
	cmp $PS2_SC_BRK, %al
	je 1f
	cmp $PS2_SC_EXT, %al
	je 2f
	jmp 3f

1:
	mov (scancode+0x01), %ah
	or $PS2_SCF_BRK, %ah
	mov %ah, (scancode+0x01)
	jmp 99f

2:
	mov (scancode+0x01), %ah
	or $PS2_SCF_EXT, %ah
	mov %ah, (scancode+0x01)
	jmp 99f

3:
	mov %al, (scancode)
	jmp 99f

4:
	in $PS2_PORT_DATA, %al
	jmp 99f

99:
	mov $EOI, %al
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret

# isr 0x08
isr_rtc:
	push %ax

	# clr int
	mov $(RTC_ADDR_REG_C|RTC_NMI), %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	mov $RTC_ADDR_REG_D, %al
	out %al, $RTC_PORT_ADDR
	in $RTC_PORT_DATA, %al

	# (init_flag != 0) ? {skip}
	mov (init_flag), %ax
	test %ax, %ax
	jnz 99f

	mov (rtc_tick), %ax
	cmp $0x0400, %ax
	jne 1f

	mov (rtc_date), %ax
	inc %ax
	mov %ax, (rtc_date)
	call rtc_upd_time

	xor %ax, %ax
	mov %ax, (rtc_tick)
	jmp 99f

1:
	inc %ax
	mov %ax, (rtc_tick)
	jmp 99f

99:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %ax
	iret

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
	jnz 99f

	mov ATA_BUF_CMD(%bx), %al
	cmp $ATA_CMD_READ, %al
	je 10f
	cmp $ATA_CMD_WRITE, %al
	je 20f
	jmp 99f

10:
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
	jmp 99f

20:
	mov ATA_BUF_CNT(%bx), %al
	dec %al
	mov %al, ATA_BUF_CNT(%bx)
	test %al, %al
	jz 99f

1:
	mov $ATA_PORT_ALT_STAT, %dx
	in %dx, %al
	test $ATA_STAT_DRQ, %al
	jz 1b

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
	jmp 99f

99:
	mov $EOI, %al
	out %al, $PIC2_PORT_CMD
	out %al, $PIC1_PORT_CMD

	pop %dx
	pop %cx
	pop %ax
	pop %bx
	iret
