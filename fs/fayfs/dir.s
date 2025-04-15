# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry (docs/fs/fayfs/dir.txt)

.code16
.section .text

.global write_dentry
.global write_dentry__type

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
  movw $0xFADE, (%si) # magic: FAcooya Directory Entry

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

# write_dentry__type(type)
write_dentry__type:
  push %bp
  mov %sp, %bp
  push %ax

  xor %ax, %ax
  mov 4(%bp), %ax
  mov %al, 9(%si)

  pop %ax
  pop %bp
  ret
