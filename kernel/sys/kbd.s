# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Keyborad services

.include "sys.s"

.section .text
.code16
.global sys_read_key

# sys_read_key()
# <RET>
# ah = scan_code
# al = ascii_code
sys_read_key:
	xor %ax, %ax
	int $INT_KBD
	ret
