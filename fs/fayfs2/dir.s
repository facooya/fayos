# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry

.include "fs.s"

# TEXT
.section .text
.code16

.global find_free_dentry
.global add_dentry

# ENTRY
# find_free_dentry(inode)
#   pre: bx = mem ptr
find_free_dentry:
  push %bx

  # set lba
  mov (cwd_lba), %ax
  push %ax
  mov (cwd_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  # read block
  call read_block
  mov $0x8000, %bx

  pop %bx
  ret

# ENTRY
# add_dentry()
#   pre: bx = free dentry mem ptr
add_dentry:
  ret