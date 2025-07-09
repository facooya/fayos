# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Keyborad services

.include "sys.s"
.section .text
.code16
.global _sys_read_key

# _sys_read_key()
# <RET>
# ah = scan_code
# al = ascii_code
_sys_read_key:
	xor %ax, %ax
	int $INT_KBD
	ret
