# SPDX-License-Identifier: GPL-3.0-or-later
#
# Metadata (docs/fs/fayfs/meta.txt)
#
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya

.code16
.section .text

.global init_root_meta
.global write_meta

.extern set_dap_lba
.extern read_block
.extern write_block
.extern cwd_lba
.extern free_lba

# init_root_meta()
init_root_meta:
  # prol
  push %si

  # set root lba
  push $0x80 # root dir
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_block
  mov $0x8000, %si

  cmp $0xFADA, 4(%si)
  jz .init_root_meta__done

  # write root metadata
  movw $0x80, (%si) # low
  movw $0x00, 2(%si) # high
  movw $0xFADA, 4(%si) # magic

  call write_block

.init_root_meta__done:
  # epil
  pop %si
  ret

# write_meta()
write_meta:
  # prol
  push %si
  push %ax

  # set lba
  mov (free_lba), %ax # low
  push %ax
  mov (free_lba+2), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block
  mov $0x8000, %si

  # write metadata
  mov (cwd_lba), %ax # low
  mov %ax, (%si)
  mov (cwd_lba+2), %ax # high
  mov %ax, 2(%si)
  mov $0xFADA, 4(%si) # magic

  call write_block

  #epil
  pop %ax
  pop %si
  ret
