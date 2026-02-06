# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

.equ FS_ROOT_INUM, 0x0001
.equ FS_START_LBA, 0x0100
.equ FS_BLK_SIZE, 0x1000
.equ FS_MASK_OFF, 0x0FFF
.equ FS_MASK_BLK, 0xF000

.equ FT_SIZE, 0x0A
.equ FT_OFF_FLG, 0x00
.equ FT_OFF_MEM, 0x02
.equ FT_IND_PTR, 0x06

.equ F_TYPE_RM, 0xFF
.equ F_TYPE_DIR, 0x40
.equ F_TYPE_FILE, 0x80

# { File System Packet
.equ FSP_SIZE, 0x2E
.equ FSP_OFF_DISK, 0x26

# Inode
.equ FSP_OFF_F_SIZE, 0x00 # [2-byte]
.equ FSP_OFF_F_TYPE, 0x02 # [1-byte]
.equ FSP_OFF_BLK_CNT, 0x03 # [1-byte]
.equ FSP_OFF_BLK, 0x04 # [2-byte] * 14

# Info
.equ FSP_OFF_IND_PTR, 0x20 # [4-byte]
.equ FSP_OFF_INUM, 0x24 # [2-byte]

# Disk
.equ FSP_OFF_DISK_SECT_CNT, 0x26 # [2-byte]
.equ FSP_OFF_DISK_MEM, 0x28 # [4-byte]
.equ FSP_OFF_DISK_LBA, 0x2C # [2-byte]

# Access
.equ FSP_OFF_CUR, 0x00
.equ FSP_OFF_PAR, FSP_SIZE
.equ FSP_OFF_TMP, FSP_SIZE*0x02
.equ FSP_OFF_DIR, FSP_SIZE*0x03
.equ FSP_OFF_BASE, FSP_SIZE*0x04
.equ FSP_OFF_ROOT, FSP_SIZE*0x05
.equ FSP_OFF_HIST, FSP_SIZE*0x06
# }

# Redir
.equ REDIR_APPEND, 0x3E3E
.equ REDIR_WRITE, 0x003E

# Dir
.equ DIR_DOTS_REC_SIZE, 0x10
