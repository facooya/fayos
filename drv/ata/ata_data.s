# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya

.section .data
.global ata_buf
ata_buf: .zero 0x06
# cmd [1-byte], cnt [1-byte], seg [2-byte], off [2-byte]
