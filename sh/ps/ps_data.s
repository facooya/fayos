# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# [Prompt String] Prompt "[ps1_name]:[ps1_path]# "

.section .data
.global ps1
.global ps1_name
.global ps1_path

ps1: .zero 0x110
ps1_name: .asciz "fayos"
ps1_path: .zero 0x100
