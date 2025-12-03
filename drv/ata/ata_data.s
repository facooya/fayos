# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .data
.global ata_stat
ata_stat: .zero 0x06
# cmd [1-byte], cnt [1-byte], seg [2-byte], off [2-byte]
