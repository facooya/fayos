# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug trace

.section .text
.code16
.global dbg_a
.global dbg_b
.global dbg_c

dbg_a:
	push %ax
	call ._prol
	mov $0x41, %al
	jmp .done

dbg_b:
	push %ax
	call ._prol
	mov $0x42, %al
	jmp .done

dbg_c:
	push %ax
	call ._prol
	mov $0x43, %al
	jmp .done

.done:
	call _sys_tty_out
	call outsp
	call dbg_line
	call outnl
	pop %ax
	ret

._prol:
	call outnl
	call dbg_line
	call outsp
	ret
