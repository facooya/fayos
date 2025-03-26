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
.global cmd_touch

# -----========== > Command (touch) ==========-----

# cmd_touch()
# cmd_table => cmd_touch()
# Block Entry => Disk Read => Directory Entry => Disk Write
cmd_touch:

# ----------===== > Touch (name) =====----------

_cmd_touch__set_dap:
  # set_dap_lba(low, high)
  push $0x00 # high
  push $0x80 # low
  call set_dap_lba # block.inc
  add $0x04, %sp

_cmd_touch__disk_read:
  # Disk Read
  push $dap
  push $0x42
  call disk_rw # block.inc
  add $0x04, %sp

_cmd_touch__find_free:
  mov $0x8000, %si

_cmd_touch__find_free_loop:
  # Null ? Check
  mov (%si), %ax
  test %ax, %ax
  or 2(%si), %ax
  jz _cmd_touch__find_free_end

  # Loop
  add $0x02, %si
  jmp _cmd_touch__find_free_loop

_cmd_touch__find_free_end:

_cmd_touch__name_set:
  #mov $arg_buf, %di
  mov $cli_buf_arg, %di
  xor %cx, %cx

_cmd_touch__name_size_loop:
  # Null ? Name Size End
  mov (%di), %al
  test %al, %al
  jz _cmd_touch__name_size_end

  # Memory Write
  mov %al, (%si)

  # Loop
  add $0x01, %si
  add $0x01, %di
  add $0x01, %cx
  jmp _cmd_touch__name_size_loop

_cmd_touch__name_size_end:

_cmd_touch__name_align:
  add $0x01, %si # Add Null
  add $0x01, %cx # Add Null Size

  # Return [SI] OR [SI]++
  push %cx # size
  call dentry_name_align # block.inc
  add $0x02, %sp

#_cmd_touch__file_type:
#  movb $0x0F, (%si) # File Type
#  movb $0x00, 1(%si) # Block Level
#  add $0x02, %si

_cmd_touch__sector_addr: # !!!!!!!!!
  # Read Master Sector
  push %si
  push $dap_master
  push $0x42
  call disk_rw
  add $0x04, %sp
  pop %si

  mov $0x0600, %di # dap_master Offset

  # Low
  mov (%di), %ax
  mov %ax, 4(%si)

  # High
  mov 2(%di), %ax
  mov %ax, 6(%si)

  # Next Sector Number !!!!! 2 Bytes
  mov (%di), %ax
  add $0x08, %ax
  mov %ax, (%di)

  # Write Master Sector
  push %si
  push $dap_master
  push $0x43
  call disk_rw
  add $0x04, %sp
  pop %si

  jmp _cmd_touch__disk_write

# ----------===== < Touch (name) =====----------

_cmd_touch__disk_write:
  push $dap
  push $0x43
  call disk_rw # block.inc
  add $0x04, %sp

  call newline

_cmd_touch__done:
  ret

# -----========== < Command (touch) ==========-----
# === < CODE
