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

# INDEX
# set_dap_lba(lba_high, lba_low)
# rw_disk(rw_mode, dap_struct)
# set_dap_target(count, segment, offset)
# reset_dap_target()
# dap
#
# .hdl_rw_disk_err

# DEPS
# .hdl_rw_disk_err
#   print_newline
#   print_str

# NOTE
# [c_disk_terms]
#   DAP: Disk Address Packet
#   LBA: Logical Bolck Address
#
# [n_set_dap]
#   [dap+2] sector count
#   [dap+4] offset
#   [dap+6] segment
#   [dap+8] lba low
#   [dap+10] lba high
#
# [n_rw_disk]
#   rw_mode: 0x42 (read), 0x43 (write)
#
# [n_dap]
#   Common
#   sector count: 8
#   mem ptr: 0x8000
#   lba low addr: 0x80-0xFFFF
#   lba high addr: 0x00-0xFFFF
#     fayos uses only 4-byte lba
# 
#   Master
#     sector count: 4
#     mem ptr: 0x0600
#     lba addr: 0x10, 0x10-0x13

.code16
.section .text

.global set_dap_lba
.global rw_disk
.global dap
.global set_dap_target
.global reset_dap_target

.extern print_newline
.extern print_str

# set_dap_lba(lba_high, lba_low), [n_set_dap]
set_dap_lba:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # set lba
  mov $dap, %si
  mov 4(%bp), %ax # high
  mov %ax, 10(%si)
  mov 6(%bp), %ax # low
  mov %ax, 8(%si)
  
  # epli
  pop %ax
  pop %si
  pop %bp
  ret

# set_dap_target(count, segment, offset) [n_set_dap]
set_dap_target:
  # prol
  push %bp
  mov %sp, %bp
  push %si
  push %ax

  # set dap target
  mov $dap, %si
  mov 4(%bp), %ax
  mov %ax, 2(%si) # count
  mov 6(%bp), %ax
  mov %ax, 6(%si) # segment
  mov 8(%bp), %ax
  mov %ax, 4(%si) # offset

  # epli
  pop %ax
  pop %si
  pop %bp
  ret

# reset_dap_target()
reset_dap_target:
  push $0x8000
  push $0x00
  push $0x08
  call set_dap_target
  add $0x06, %sp
  ret

# rw_disk(rw_mode, dap_struct) [n_rw_disk] !!! only get mode
rw_disk:
  # prol
  push %bp
  mov %sp, %bp
  push %ax
  push %dx
  push %si

  # try
  clc
  mov 4(%bp), %ah
  mov 6(%bp), %si
  mov $0x80, %dl
  int $0x13
  jc .hdl_rw_disk_err

  # epil
  pop %si
  pop %dx
  pop %ax
  pop %bp
  ret

# .hdl_rw_disk_err
.hdl_rw_disk_err:
  call print_newline

  push $.disk_err_msg
  call print_str
  add $0x02, %sp

  call print_newline
  ret

.section .data

# dap
dap: # [n_dap]
  .byte 0x10
  .byte 0x00
  .word 0x08
  .word 0x8000
  .word 0x00
  .word 0x80
  .word 0x00 
  .word 0x00
  .word 0x00

# msg
.disk_err_msg: .asciz "Disk error." 
