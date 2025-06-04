# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Keyborad services

.include "sys.s"

.section .text
.code16
.global sys_read_key

# ENTRY
# sys_read_key()
# ret: ah = scan code
# ret: al = ascii code
sys_read_key:
	xor %ah, %ah # KBD_READ_KEY
	int $INT_KBD
	ret
