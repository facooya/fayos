# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make directory 2 for fayfs 2, Temporary command

.section .text
.code16

.global cmd_mkdir2

# ENTRY
# cmd_mkdir2()
cmd_mkdir2:
  call outnl
  
  call write_inode

  mov $0x40, %ax
  push %ax
  call write_dentry2
  add $0x02, %sp

  ret
