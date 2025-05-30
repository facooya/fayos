# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Argments main

.section .data
.global argc
.global argv
.global argv_1

.global args
.global args_info

# args
argc: .word 0x00
argv: .zero 0x100
argv_1: .word 0x00

args: .zero 0x100
args_info: .quad 0x00
# opt_c, opt_idx, arg_c, arg_idx
