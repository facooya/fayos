# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Argments main
#
# NOTE
# [n_args]
# argc [2-byte]
# optc [2-byte]
# argv [2-byte]-[156-byte]

.section .data
.global argc
.global argv
.global argv_1

.global args

# args
argc: .word 0x00
argv: .zero 0x100
argv_1: .word 0x00

args: .zero 0x100
