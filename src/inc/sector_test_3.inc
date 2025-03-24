.code16
# Preview Function
# set_dap(count, low, high)
# disk_rw(mode)
#
# Preview Data
# dap
# =============== > Code ===============
# -----========== > Set DAP ==========-----

# set_dap(count, low, high)
# count: Block Count (DAP + 2)
# low: LBA Low Address (DAP + 8)
# high: LBA High Address (DAP + 10)
set_dap:
_set_dap__set_bp:
  push %bp
  mov %sp, %bp

_set_dap__set_bx:
  push %bx
  mov $dap, %bx

_set_dap__push:
  push %ax

_set_dap__run:
  movw 4(%bp), %ax # count
  movw %ax, 2(%bx) # DAP + 2

  movw 6(%bp), %ax # low
  movw %ax, 8(%bx) # DAP + 8

  movw 8(%bp), %ax # high
  movw %ax, 10(%bx) # DAP + 10
  
_set_dap__pop:
  pop %ax
  pop %bx
  pop %bp

_set_dap__done:
  ret

# -----========== < Set DAP ==========-----
# -----========== > Disk Read Write ==========-----

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

  jc _disk_err # CF ? Error

_disk_rw__pop:
  pop %si
  pop %dx
  pop %ax
  pop %bp

_disk_rw__done:
  ret

# -----========== < Disk Read Write  ==========-----
# -----========== > Word Align  ==========-----

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

  # Memory Index
  add %dx, %si # Memory Index

  # Magic
  movw $0xFADE, (%si) # 0xFADE: FacooyA Directory Entry
  add $0x02, %si

  # Name Size
  movb 4(%bp), %al
  mov %al, (%si)
  
  # Padding Flag
  inc %si
  add %dl, (%si)

  inc %si # For Next (File Type)

  # Pop
  pop %dx
  pop %bx
  pop %ax
  pop %bp
  ret

# -----========== < Word Align  ==========-----

_disk_err:
  mov %ah, %al
  mov $0x0E, %ah
  int $0x10

  call newline
  # Print
  push $_disk_err_msg
  call print_str
  add $0x02, %sp

  call newline
  ret

master_sector:
_master_sector__set:
  push %si
  push %ax

  push $dap_master
  push $0x42
  call disk_rw
  add $0x04, %sp

_master_sector__chk:
  # !Null ? Done
  mov $0x0600, %si
  mov (%si), %ax
  or 2(%si), %ax
  jnz _master_sector__done

_master_sector__base:
  # 0x11: Root Directory, 0x12: Assign Start
  mov $0x12, %ax
  movw %ax, (%si)

_master_sector__write:
  push $dap_master
  push $0x43
  call disk_rw
  add $0x04, %sp

_master_sector__done:
  pop %ax
  pop %si
  ret

# =============== < Code ===============
# =============== > Data ===============
# -----========== > DAP ==========-----

dap: # Disk Address Packet
  .byte 0x10 # DAP Size
  .byte 0x00 # Reserved
  .word 0x00 # Block Count, Min: 1
  .long 0x00008000 # Segment:Offset, [CS]:[IP]
  .word 0x00 # Low Address (LBA)
  .word 0x00 # High Address (LBA)
  .word 0x00 # (LBA) Unset in Facooya OS
  .word 0x00 # (LBA) Unset in Facooya OS

dap_master: # Master Block
  .byte 0x10
  .byte 0x00
  .word 0x01
  .long 0x00000600
  .word 0x10
  .word 0x00
  .word 0x00
  .word 0x00

# Master Block: 0x10

# -----========== < DAP ==========-----
# -----========== > Message ==========-----

_disk_err_msg: .asciz "Disk Error."

# -----========== < Message ==========-----
# =============== < Data ===============

# Master Block
# Next Free Block: 4 Bytes
# Next Directory Entry:
# Delete Block List: 4 Bytes
# ...


# Directory Entry (dentry) [Min: 12 Bytes - Max: 512 Bytes]
# Name: 2 - 504 Bytes, Char [1 Byte] + Null [1 Byte] = Name [2 Bytes]
# Align: 0 - 1 Byte, Even [0 Byte], Odd [1 Byte]
#
# Magic Number: 2 Bytes, 0xFADE: FacooyA Directory Entry
#
# Name Size: 1 Byte, String + Null [1 Byte] = Name Size
# Padding: 1 Byte, 0x00 None, 0x01 True
#
# File Type: 1 Bytes, FT
# Block Level: 1 Bytes
#
# Block Entry: 4 Bytes
#
# FT: 0x0F: File, 0x0E: Execute, 0x0D: Directory, 0xE3: Delete (dElEtE)
# BL: 0x00: Direct, 0x01: Single, 0x02: Double, 0x03: Triple
# DATA > 512: Assign New Block -> Block Entry Write -> New Block
# -> Block Entry Change, Block Level Change


# Block Entry
# Block Entry: 4 Bytes
# ...
# OR Data
# ...

# Data (Directory)
# Directory Entry Data
# ...

# Data (File)
# Data
# ...

# Temporary
# Master Block: 0x10
# Normal Block Start: 0x11

# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
