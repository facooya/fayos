# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Memory cache

.section .data
.global memnum
.global mem_bitmap

memnum: .word 0x00
mem_bitmap: .zero 0x10
