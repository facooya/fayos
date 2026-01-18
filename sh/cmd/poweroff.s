# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.equ APM_CMD_CHK_VER, 0x5300
.equ APM_CMD_CONN_REAL, 0x5301
.equ APM_CMD_STAT, 0x5307
.equ APM_CMD_ENABLE, 0x530E

.equ APM_STAT_ALL, 0x01
.equ APM_STAT_OFF, 0x03

.equ BIOS_SYSTEM, 0x15

.include "chr.inc"
.section .text
.code16
.global cmd_poweroff

# cmd_poweroff()
cmd_poweroff:
	push %bx

	# chk ver
	mov $APM_CMD_CHK_VER, %ax
	xor %bx, %bx
	int $BIOS_SYSTEM
	jc 80f
	push %ax # [s.0: apm_ver]

	# connect
	mov $APM_CMD_CONN_REAL, %ax
	xor %bx, %bx
	int $BIOS_SYSTEM
	jc 80f

	# (apm_ver == 1.0) ? {skip}
	pop %cx # [s.0: apm_ver]
	cmp $0x0100, %cx
	je 1f

	# enable
	mov $APM_CMD_ENABLE, %ax
	xor %bx, %bx
	int $BIOS_SYSTEM
	jc 80f

1:
	# power off
	mov $APM_CMD_STAT, %ax
	mov $APM_STAT_ALL, %bx
	mov $APM_STAT_OFF, %cx
	int $BIOS_SYSTEM
	jmp 80f

80:
	# err
	push $_emsg_cmd_fail
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc
	jmp 99f

99:
	pop %bx
	ret

.section .data
_emsg_cmd_fail: .asciz "Command failure."
