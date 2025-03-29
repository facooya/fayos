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

# === > CODE

.code16
.section .text

.global cmd_ls

.extern rw_disk

# -----========== > Command (ls) ==========-----

# Current Directory !!!
# Find Magic, Name Size, Padding, Next Magic ...
cmd_ls:

_cmd_ls__set_dap:
  # Set DAP
  push $0x00 # high
  push $0x80 # low
  call set_dap_lba # block.inc
  add $0x04, %sp

_cmd_ls__read:
  # Disk Read
  push $dap
  push $0x42
  call rw_disk
  add $0x04, %sp

  # Newline
  call newline

  # Ready
  mov $0x8000, %si

_cmd_ls__magic_loop:
  # Magic ? Name Set
  mov (%si), %ax
  cmp $0xFADE, %ax
  je _cmd_ls__name_set

  # Null ? Done
  test %ax, %ax
  or 2(%si), %ax
  jz _cmd_ls__done

  # Loop
  add $0x02, %si
  jmp _cmd_ls__magic_loop

_cmd_ls__name_set:
  # Set
  mov %si, %di # Magic
  #add $0x02, %si

  # CL = Name Size + Name Align
  xor %cx, %cx # Init
  mov 2(%si), %cl # Name Size
  add 3(%si), %cl # Name Align

  # DI = Name Start Pointer
  sub %cx, %di
  mov $0x0E, %ah # Print

_cmd_ls__name_loop:
  # Null ? End
  mov (%di), %al
  test %al, %al
  jz _cmd_ls__name_end

  # Print
  int $0x10

  # Loop
  inc %di
  jmp _cmd_ls__name_loop

_cmd_ls__name_end:
  # Skip Directory Entry
  add $0x0A, %si # 2 (MN) + 1 (NS) + 1 (PD) + 4 (BE) + 1 (EL) + 1 (FT) = 10, NOTE Dentry

  # Space * 2
  mov $0x20, %al
  int $0x10
  int $0x10
  
  # Next Magic Check
  jmp _cmd_ls__magic_loop

_cmd_ls__done:
  call newline
  ret

# -----========== < Command (ls) ==========-----
# === < CODE
# =============== > NOTE ===============
# -----========== > Dentry ==========-----

# NOTE ID: Dentry
# Dentry: Directory Entry
# DN: Directory Name
# NP: Name Padding
# MN: Magic Number
# NS: Name Size
# PS: Padding Size
# BE: Block Entry
# EL: Entry Level
# FT: File Type

# -----========== < Dentry ==========-----

# =============== < NOTE ===============
