# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Fixed character output with no arguments

.section .text
.code16
.global outc
.global outcol
.global outnl
.global outsp

# ENTRY
# outc() - out character
outc:
	# pre: al = chr

	call sys_tty_out
	ret

# ENTRY
# outcol() - out colon
outcol:
	mov $0x3A, %al
	call sys_tty_out
	ret

# ENTRY
# outnl() - out newline
outnl:
	mov $0x0D, %al # CR
	call sys_tty_out
	mov $0x0A, %al # LF
	call sys_tty_out
	ret

# ENTRY
# outsp() - out space
outsp:
	mov $0x20, %al
	call sys_tty_out
	ret

