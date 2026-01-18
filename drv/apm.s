# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2026 Facooya and Fanone Facooya

.include "chr.inc"
.include "drv/apm.inc"
.section .text
.code16
.global apm_init
.global apm_off

# apm_init()
apm_init:
	push %bx

	# chk ver
	clc
	mov $APM_CMD_CHK_VER, %ax
	mov $APM_ID_SYS, %bx
	int $BIOS_SYSTEM
	jc 81f
	push %ax # [s.0: apm_ver]

	# connect
	clc
	mov $APM_CMD_CONN_REAL, %ax
	mov $APM_ID_SYS, %bx
	int $BIOS_SYSTEM
	jc 82f

	# (ver == old_ver) ? {skip}
	pop %cx # [s.0: apm_ver]
	cmp $APM_OLD_VER, %cx
	je 99f

	# enable
	clc
	mov $APM_CMD_ENABLE, %ax
	mov $APM_ID_SYS, %bx
	int $BIOS_SYSTEM
	jc 83f
	jmp 99f

81:
	push $_emsg_apm_no
	jmp 8090f

82:
	pop %ax # [s.0: apm_ver]
	push $_emsg_apm_conn
	jmp 8090f

83:
	push $_emsg_apm_enable
	jmp 8090f

8090:
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

# apm_off()
apm_off:
	push %bx

	mov $APM_CMD_STAT, %ax
	mov $APM_STAT_ALL, %bx
	mov $APM_STAT_OFF, %cx
	int $BIOS_SYSTEM

	# err
	mov %ah, %al
	call vga_outc
	mov $CHR_COL, %al
	call vga_outc
	mov $CHR_SP, %al
	call vga_outc
	push $_emsg_cmd_fail
	call vga_outs
	add $0x02, %sp
	mov $CHR_CR, %al
	call vga_outc
	mov $CHR_LF, %al
	call vga_outc

	pop %bx
	ret

.section .data
_emsg_cmd_fail: .asciz "Command poweroff failure."
_emsg_apm_no: .asciz "APM not found."
_emsg_apm_conn: .asciz "APM connect failure."
_emsg_apm_enable: .asciz "APM enable failure."
