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
# [n_dap_master]
# - Sector count: 4
# - Offset: 0x0600
# - LBA addr: 0x10, 0x10-0x13

# DEPS
# .hdl_rw_disk_err
# - print_newline
# - print_str

.code16
.section .text

.global set_dap_lba, rw_disk, dentry_name_align, master_block
.global dap, dap_master

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

# !!! temporary
# dentry_name_align(name_size)
# name_size: name_size / 2 = Even [0 Bytes], Odd [1 Bytes] [SI]++
dentry_name_align:
  # prol
  push %sp
  mov %sp, %bp
  push %ax
  push %bx
  push %dx

  # div for align
  mov 4(%bp), %ax
  mov $0x02, %bx
  xor %dx, %dx
  div %bx

  # dentry magic
  add %dx, %si # mem align
  movw $0xFADE, (%si) # magic: FacooyA Directory Entry

  # dentry name
  mov 4(%bp), %al
  mov %al, 2(%si) # name size
  mov %dl, 3(%si) # name align

  # dentry etc
  movb $0x01, 8(%si) # entry level
  movb $0xFE, 9(%si) # file type

  # epil
  pop %dx
  pop %bx
  pop %ax
  pop %bp
  ret

# master_block()
master_block:
  push %si
  push %ax

  # read disk
  push $dap_master
  push $0x42
  call rw_disk
  add $0x04, %sp

  # cond: null != ? done
  mov $0x0600, %si
  mov (%si), %ax
  or 2(%si), %ax
  jnz .master_block__done

  # write mem
  mov $0x80, %ax # root dir
  mov %ax, (%si)

  # write disk
  push $dap_master
  push $0x43
  call rw_disk
  add $0x04, %sp

.master_block__done:
  pop %ax
  pop %si
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

dap_master: # [n_dap_master]
  .byte 0x10
  .byte 0x00
  .word 0x04
  .word 0x0600
  .word 0x00
  .word 0x10
  .word 0x00
  .word 0x00
  .word 0x00

.disk_err_msg: .asciz "Disk error." 
