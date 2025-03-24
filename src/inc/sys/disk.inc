# FAYOS - FAcooYa Operating System
# Copyright (C) 2025 Facooya
# Copyright (C) 2025 Fanone Facooya
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# === > PREVIEW

# FUNC
# set_dap_lba(low, high)
# disk_rw(mode)
# dentry_name_align(name_size)
# master_block()

# DATA
# dap
# dap_master

# === < PREVIEW
# ===
# === > CODE

.code16

# -== > Set DAP

# set_dap_lba(low, high)
# low: LBA Low Address (DAP + 8)
# high: LBA High Address (DAP + 10)
set_dap_lba:
_set_dap_lba__set_bp:
  push %bp
  mov %sp, %bp

_set_dap_lba__set_bx:
  push %bx
  mov $dap, %bx

_set_dap_lba__push:
  push %ax

_set_dap_lba__run:
  movw 4(%bp), %ax # low
  movw %ax, 8(%bx) # DAP + 8

  movw 6(%bp), %ax # high
  movw %ax, 10(%bx) # DAP + 10
  
_set_dap_lba__pop:
  pop %ax
  pop %bx
  pop %bp

_set_dap_lba__done:
  ret

# -== < Set DAP
# ===
# -== > Disk Read Write

# disk_rw(mode, &DAP)
# mode: 0x42 (Read), 0x43 (Write)
# DAP: Disk Address Packet (Struct)
disk_rw:
_disk_rw__set_bp:
  push %bp
  mov %sp, %bp

_disk_rw__push:
  push %ax
  push %dx
  push %si

_disk_rw__run:
  clc # Clear Carry Flag
  mov 4(%bp), %ah # mode
  mov 6(%bp), %si # DAP

  mov $0x80, %dl # First Hard Disk
  int $0x13 # Disk Interrupt

  jc err_disk # CF ? Error, ref: err.inc

_disk_rw__pop:
  pop %si
  pop %dx
  pop %ax
  pop %bp

_disk_rw__done:
  ret

# -== < Disk Read Write 
# ===
# -== > Word Align 

# dentry_name_align(name_size)
# name_size: name_size / 2 = Even [0 Bytes], Odd [1 Bytes] [SI]++
dentry_name_align:
  push %sp
  mov %sp, %bp

  # Push
  push %ax
  push %bx
  push %dx

  # Division
  mov 4(%bp), %ax
  mov $0x02, %bx
  xor %dx, %dx
  div %bx

  # Memory Offset
  add %dx, %si # Memory Offset

  # Add Magic
  movw $0xFADE, (%si) # 0xFADE: FacooyA Directory Entry

  # Add Name Size
  mov 4(%bp), %al
  mov %al, 2(%si)
  
  # Add Name Align
  mov %dl, 3(%si)

  # Add Entry Level
  movb $0x01, 8(%si)

  # Add File Type
  movb $0xFE, 9(%si)

  # Pop
  pop %dx
  pop %bx
  pop %ax
  pop %bp
  ret

# -== < Word Align

master_block:
_master_block__set:
  push %si
  push %ax

  push $dap_master
  push $0x42
  call disk_rw
  add $0x04, %sp

_master_block__chk:
  # !Null ? Done
  mov $0x0600, %si
  mov (%si), %ax
  or 2(%si), %ax
  jnz _master_block__done

_master_block__base:
  # 0x80: Root Directory, 0x88: Assign Start
  mov $0x80, %ax
  movw %ax, (%si)

_master_block__write:
  push $dap_master
  push $0x43
  call disk_rw
  add $0x04, %sp

_master_block__done:
  pop %ax
  pop %si
  ret

# === < CODE
# ===
# === > DATA
# ===
# -== > DAP

dap: # Disk Address Packet
  .byte 0x10 # DAP Size
  .byte 0x00 # Reserved
  .word 0x08 # Sector Count, Block: 512 * 8
  .word 0x8000 # Offset, REG IP
  .word 0x0000 # Segment, REG CS
  .word 0x80 # Low Address (LBA), 0x80 - 0xFFFF
  .word 0x00 # High Address (LBA), 0x00 - 0xFFFF
  .word 0x00 # (LBA) Unset in Facooya OS
  .word 0x00 # (LBA) Unset in Facooya OS

dap_master: # Master Block
  .byte 0x10
  .byte 0x00
  .word 0x04 # Sector Count, Master Block: 512 * 4, 0x0600 - 0x0FFF
  .long 0x00000600
  .word 0x10 # Address (LBA), 0x10 - 0x13
  .word 0x00 # (LBA) Unset in master block
  .word 0x00 # (LBA) Unset in Fayos
  .word 0x00 # (LBA) Unset in Fayos

# Master Block: 0x10

# -== < DAP
# ===
# === < DATA
# ===
# === > FACOOYA
# Copyright 2025 Facooya.
# === < FACOOYA
