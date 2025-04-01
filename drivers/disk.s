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
# set_dap_lba()
# set_meta_dap_lba() !!! test
# rw_disk()
# dap
# master_dap
# meta_dap
#
# .hdl_rw_disk_err

# DEPS
# .hdl_rw_disk_err
# - print_newline
# - print_str

# NOTE
# [n_set_dap_lba]
# - set_dap_lba(lba_low_addr, lba_high_addr)
# - lba_low_addr (DAP + 8)
# - lba_high_addr (DAP + 10)
#
# [n_rw_disk]
# - rw_disk(rw_mode, dap_struct_addr)
# - rw_mode 0x42 (read), 0x43 (write)
#
# [n_dap]
# - Sector count: 8
# - Offset: 0x8000
# - Fayos uses only 4-byte LBA.
# - LBA low addr: 0x80-0xFFFF
# - LBA high addr: 0x00-0xFFFF
#
# [n_master_dap]
# - Sector count: 4
# - Offset: 0x0600
# - LBA addr: 0x10, 0x10-0x13

.code16
.section .text

.global set_dap_lba
.global set_meta_dap_lba # !!! test
.global rw_disk
.global dap
.global master_dap
.global meta_dap

.extern print_newline
.extern print_str

# set_dap_lba(lba_low_addr, lba_high_addr), [n_set_dap_lba]
set_dap_lba:
  # prol
  push %bp
  mov %sp, %bp
  push %bx
  push %ax

  # set
  mov $dap, %bx
  mov 4(%bp), %ax # low
  mov %ax, 8(%bx)
  mov 6(%bp), %ax # high
  mov %ax, 10(%bx)
  
  # epli
  pop %ax
  pop %bx
  pop %bp
  ret

# set_meta_dap_lba(lba_low_addr, lba_high_addr) !!! test
set_meta_dap_lba:
  # prol
  push %bp
  mov %sp, %bp
  push %bx
  push %ax

  # set
  mov $meta_dap, %bx
  mov 4(%bp), %ax # low
  mov %ax, 8(%bx)
  mov 6(%bp), %ax # high
  mov %ax, 10(%bx)
  
  # epli
  pop %ax
  pop %bx
  pop %bp
  ret

# rw_disk(rw_mode, dap_struct_addr) [n_rw_disk]
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

# master_dap
master_dap: # [n_master_dap]
  .byte 0x10
  .byte 0x00
  .word 0x04
  .word 0x0600
  .word 0x00
  .word 0x10
  .word 0x00
  .word 0x00
  .word 0x00

# meta_dap
meta_dap:
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
