# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Directory entry (docs/fs/fayfs/dir.txt)

.code16
.section .text

.global write_dentry
.global write_dentry__type
.global write_dentry2
.global write_dentry__type2

# write_dentry(name_size) [n_write_dentry]
write_dentry:
  # prol
  push %bp
  mov %sp, %bp
  push %ax
  push %dx

  # div for align
  xor %cx, %cx
  xor %dx, %dx
  mov 4(%bp), %ax
  mov $0x02, %cx
  div %cx

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
  pop %ax
  pop %bp
  ret

# ENTRY
# write_dentry2(name_size) [n_write_dentry]
#   pre: bx = mem ptr
#   ret: bx += align
write_dentry2:
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

# ENTRY
# write_dentry__type2(type)
#   pre: bx = mem ptr
write_dentry__type2:
  push %bp
  mov %sp, %bp

  xor %ax, %ax
  mov 4(%bp), %ax
  mov %al, 9(%bx)

  pop %bp
  ret

