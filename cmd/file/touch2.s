# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Touch 2 for fayfs 2, Temporary command

.section .text
.code16

.global cmd_touch2

# ENTRY
# cmd_touch2()
cmd_touch2:
  call outnl
  call add_dentry
  ret
