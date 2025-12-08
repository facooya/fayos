# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .text
.code16
.global ps2_init

# ps2_init()
ps2_init:
	call ps2_xlate_off
	call ps2_chk_sc_set
	ret
