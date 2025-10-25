# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

# Inode number
.equ DE_INUM_OFF, 0x00

# Record length
.equ DE_REC_LEN_OFF, 0x04

# Information
.equ DE_FILE_TYPE_OFF, 0x06
.equ DE_NAME_LEN_OFF, 0x07

# Name
.equ DE_NAME_OFF, 0x08

# Dots
.equ DE_DOT, 0x002E
.equ DE_DOT_INFO, 0x4001
.equ DE_DOTS, 0x2E2E
.equ DE_DOTS_INFO, 0x0240
