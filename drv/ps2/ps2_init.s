# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# PS/2 initialization

.section .text
.code16
.global ps2_init

# ps2_init()
ps2_init:
	call ps2_xlate_off
	ret
