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

.global cmd_cat

# -----========== > Command (cat) ==========-----

cmd_cat:
_cmd_cat__set_dap:
  # Set DAP
  push $0x00 # high
  push $0x80 # low
  call set_dap_lba # block.inc
  add $0x04, %sp

_cmd_cat__disk_read:
  # Disk Read
  push $dap
  push $0x42
  call disk_rw # block.inc
  add $0x04, %sp

  # Newline
  call newline

  # Memory
  mov $0x8000, %si

_cmd_cat__magic_loop:
  # Magic ? Compare Name
  mov (%si), %ax
  cmp $0xFADE, %ax
  je _cmd_cat__cmp_name_set

  # Null ? Done
  mov (%si), %ax
  or 2(%si), %ax
  jz _cmd_cat__done

  # Loop
  add $0x02, %si
  jmp _cmd_cat__magic_loop

_cmd_cat__cmp_name_set:
  mov %si, %di # [DI]: Magic

  xor %cx, %cx # Init
  mov 2(%si), %cl # Name Size
  add 3(%si), %cl # Name Align

  sub %cx, %di # [DI]: File Name

  push %si # Magic
  #mov $arg_buf, %si
  mov $cli_buf_arg, %si

_cmd_cat__cmp_name_loop:
  # [CX] == 0 ? Match
  test %cx, %cx
  jz _cmd_cat__cmp_name_match

  # [DI] != [SI] ? No Match  
  mov (%si), %al
  cmp (%di), %al
  jne _cmd_cat__cmp_name_no_match

  # Loop
  add $0x01, %si
  add $0x01, %di
  sub $0x01, %cx
  jmp _cmd_cat__cmp_name_loop

_cmd_cat__cmp_name_no_match:
  pop %si # [SI]: Memory Address

  mov $0x0E, %ah
  mov $'N', %al
  int $0x10

  # [SI]: Magic
  add $0x0A, %si  # [SI]: Next Name
  jmp _cmd_cat__magic_loop

_cmd_cat__cmp_name_match:
  # Print Data
  pop %si # [SI]: Memory Address, Magic

  mov $0x0E, %ah
  mov $'M', %al
  int $0x10

  # Block Level Check
  mov 8(%si), %al # Entry Level
  cmp $0x01, %al
  jnz _cmd_cat__done # Only Direct Block

  # set_dap_lba(low, high)
  mov 6(%si), %ax
  push %ax # high
  mov 4(%si), %ax
  push %ax # low
  call set_dap_lba # block.inc
  add $0x04, %sp
  
  # disk_rw(mode, &DAP)
  push $dap
  push $0x42
  call disk_rw
  add $0x04, %sp

  # Data Read Set
  mov $0x8000, %si
  mov $0x0E, %ah

_cmd_cat__print_loop:
  # Null ? Done
  movb (%si), %al
  test %al, %al
  jz _cmd_cat__done

  # Print
  int $0x10

  # Loop
  add $0x01, %si
  jmp _cmd_cat__print_loop

_cmd_cat__done:
  ret

# -----========== < Command (cat) ==========-----
# === < CODE
