# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Metadata (docs/fs/fayfs/meta.txt)

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
  push %bx

  # set root lba
  push $0x80 # root dir
  push $0x00
  call set_dap_lba
  add $0x04, %sp

  call read_block
  mov $0x8000, %bx

  cmp $0xFADA, 4(%bx)
  jz .init_root_meta__done

  # write root metadata
  movw $0x80, (%bx) # low
  movw $0x00, 2(%bx) # high
  movw $0xFADA, 4(%bx) # magic

  call write_block

.init_root_meta__done:
  # epil
  pop %bx
  ret

# write_meta()
write_meta:
  # prol
  push %bx

  # set lba
  mov (free_lba), %ax # low
  push %ax
  mov (free_lba+2), %ax # high
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block
  mov $0x8000, %bx

  # write metadata
  mov (cwd_lba), %ax # low
  mov %ax, (%bx)
  mov (cwd_lba+2), %ax # high
  mov %ax, 2(%bx)
  mov $0xFADA, 4(%bx) # magic

  call write_block

  #epil
  pop %bx
  ret
