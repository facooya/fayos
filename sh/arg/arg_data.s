# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Argument] Data

.section .data
.global arg_ccv
arg_ccv: .zero 0x100
# argc [2-byte]
# optc [2-byte]
# argv [2-byte]-[156-byte]

