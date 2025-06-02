# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Debug trace

.section .text
.code16
.global dt_a
.global dt_b
.global dt_c

dt_a:
	push %ax
	call ._prol
	mov $0x41, %al
	jmp .done

dt_b:
	push %ax
	call ._prol
	mov $0x42, %al
	jmp .done

dt_c:
	push %ax
	call ._prol
	mov $0x43, %al
	jmp .done

.done:
	call sys_tty_out
	call outcol
	call outnl
	pop %ax
	ret

._prol:
	call outnl
	call outcol
	ret
