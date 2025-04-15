# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Allocate LBA (docs/fs/fayfs/alloc.txt)

.code16
.section .text

.global init_free_lba

.extern free_lba
.extern read_block

init_free_lba:
  # prol
  push %si
  push %ax

  # mem ptr
  mov $0x8000, %si

.init_free_lba__lp:
  # set dap lba
  mov (free_lba), %ax
  push %ax
  mov (free_lba+2), %ax
  push %ax
  call set_dap_lba
  add $0x04, %sp

  call read_block

  # cond: null ? done
  mov (%si), %ax
  test %ax, %ax
  or 2(%si), %ax
  jz .init_free_lba__done

  # loop
  mov (free_lba), %ax
  add $0x08, %ax
  mov %ax, (free_lba)
  jmp .init_free_lba__lp

.init_free_lba__done:
  # epil
  pop %ax
  pop %si
  ret
