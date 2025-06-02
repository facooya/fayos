# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Out utilities

.include "chr.s"
.section .text
.code16
.global outc
.global outcol
.global outnl
.global outsp

# outc()
outc:
	call sys_tty_out
	ret

# outcol()
outcol:
	mov $CHR_COL, %al
	call sys_tty_out
	ret

# outnl()
outnl:
	mov $CHR_CR, %al
	call sys_tty_out
	mov $CHR_LF, %al
	call sys_tty_out
	ret

# outsp()
outsp:
	mov $CHR_SP, %al
	call sys_tty_out
	ret

