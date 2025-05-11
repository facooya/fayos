# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

# Inode number
.equ DE_I_NUM_LO_OFF, 0x00
.equ DE_I_NUM_HI_OFF, 0x02

# Record length
.equ DE_REC_LEN_OFF, 0x04

# Name length
.equ DE_NAME_LEN_OFF, 0x06

# File type
.equ DE_FILE_TYPE_OFF, 0x07

# Name
.equ DE_NAME_OFF, 0x08
