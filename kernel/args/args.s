# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Argments main

.section .data
.global argc
.global argv
.global argv_1

# args
argc: .word 0x00
argv: .zero 0x100
argv_1: .word 0x00
