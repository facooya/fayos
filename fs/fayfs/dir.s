# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry (docs/fs/fayfs/dir.txt)

.code16
.section .text

.global write_dentry
.global write_dentry__type

# ENTRY
# write_dentry(name_size) [n_write_dentry]
#   pre: bx = mem ptr
#   ret: bx += align
write_dentry:
  # prol
  push %bp
  mov %sp, %bp

  # div for align
  xor %cx, %cx
  xor %dx, %dx
  mov 4(%bp), %ax
  mov $0x02, %cx
  div %cx

  # dentry magic
  add %dx, %bx # mem align
  movw $0xFADE, (%bx) # magic: FAcooya Directory Entry

  # dentry name
  mov 4(%bp), %al
  mov %al, 2(%bx) # name size
  mov %dl, 3(%bx) # name align

  # dentry etc
  movb $0x01, 8(%bx) # entry level
  movb $0x0F, 9(%bx) # file type

  # epil
  pop %bp
  ret

# ENTRY
# write_dentry__type(type)
#   pre: bx = mem ptr
write_dentry__type:
  push %bp
  mov %sp, %bp

  xor %ax, %ax
  mov 4(%bp), %ax
  mov %al, 9(%bx)

  pop %bp
  ret

