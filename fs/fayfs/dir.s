# SPDX-License-Identifier: GPL-3.0-or-later
#
# Directory entry (docs/fs/fayfs/dir.txt)
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

.code16
.section .text

.global write_dentry

# write_dentry(name_size) [n_write_dentry]
write_dentry:
  # prol
  push %bp
  mov %sp, %bp
  push %ax
  push %bx
  push %dx

  # div for align
  mov 4(%bp), %ax
  mov $0x02, %bx
  xor %dx, %dx
  div %bx

  # dentry magic
  add %dx, %si # mem align
  movw $0xFADE, (%si) # magic: FacooyA Directory Entry

  # dentry name
  mov 4(%bp), %al
  mov %al, 2(%si) # name size
  mov %dl, 3(%si) # name align

  # dentry etc
  movb $0x01, 8(%si) # entry level
  movb $0x0F, 9(%si) # file type

  # epil
  pop %dx
  pop %bx
  pop %ax
  pop %bp
  ret
