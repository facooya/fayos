.code16
# =============== > Commands ===============
# -----========== > Command (touch) ==========-----

# cmd_touch()
# cmd_table => cmd_touch()
# sector => Disk Read => Directory Entry => Disk Write
cmd_touch:

# ----------===== > Touch (name) =====----------

_cmd_touch__set_dap:
  # Set DAP
  push $0x00
  push $0x11 # Test
  push $0x01
  call set_dap # sector.inc
  add $0x06, %sp

_cmd_touch__disk_read:
  # Disk Read
  push $0x42
  call disk_rw # sector.inc
  add $0x02, %sp

_cmd_touch__find_free:
  mov $0x8000, %si

_cmd_touch__find_free_loop:
  # Null ? Check
  movw (%si), %ax
  test %ax, %ax
  jz _cmd_touch__find_free_chk

  # Loop
  add $0x02, %si
  jmp _cmd_touch__find_free_loop
  
_cmd_touch__find_free_chk:
  # 2(SI) = Null ? End
  movw 2(%si), %ax
  test %ax, %ax
  jz _cmd_touch__find_free_end

  # Loop
  add $0x02, %si
  jmp _cmd_touch__find_free_loop

_cmd_touch__find_free_end:

_cmd_touch__name_set:
  mov $arg_buf, %di
  mov $0x00, %cx

_cmd_touch__name_size_loop:
  # Null ? Name Size End
  mov (%di), %al
  test %al, %al
  jz _cmd_touch__name_size_end

  # Memory Write
  mov %al, (%si)

  # Loop
  inc %si
  inc %di
  inc %cx
  jmp _cmd_touch__name_size_loop

_cmd_touch__name_size_end:

_cmd_touch__name_align:
  inc %si # Add Null
  inc %cx # Add Null Size

  # Return [SI] OR [SI]++
  push %cx
  call dentry_name_align # sector.inc
  add $0x02, %sp

_cmd_touch__file_type:
  movw $0x000F, (%si)
  add $0x02, %si

_cmd_touch__sector_addr:
  # Low
  mov $0x5678, %ax
  movw %ax, (%si)
  add $0x02, %si

  # High
  mov $0x1234, %ax
  movw %ax, (%si)
  add $0x02, %si

  jmp _cmd_touch__disk_write

# ----------===== < Touch (name) =====----------

_cmd_touch__disk_write:
  push $0x43
  call disk_rw # sector.inc
  add $0x02, %sp

  call newline

_cmd_touch__done:
  ret

# -----========== < Command (touch) ==========-----
# -----========== > Command (ls) ==========-----

# Current Directory !!!
# Find Magic, Name Size, Padding, Next Magic ...
cmd_ls:

_cmd_ls__set_dap:
  # Set DAP
  push $0x00
  push $0x11 # Test
  push $0x01
  call set_dap # sector.inc
  add $0x06, %sp

_cmd_ls__read:
  # Disk Read
  push $0x42
  call disk_rw
  add $0x02, %sp

  # Newline
  call newline

  # Ready
  mov $0x8000, %si

_cmd_ls__magic_loop:
  # Magic ? File Name
  movw (%si), %bx
  cmp $0xFADE, %bx
  je _cmd_ls__name_set

  # Null ? Null Check
  #movw (%si), %ax
  test %bx, %bx
  jz _cmd_ls__magic_null

  # Loop
  add $0x02, %si
  jmp _cmd_ls__magic_loop

_cmd_ls__magic_null:
  # SI + 2 = Null ? End
  movw 2(%si), %bx
  test %bx, %bx
  jz _cmd_ls__done

  # Continue
  add $0x02, %si
  jmp _cmd_ls__magic_loop

_cmd_ls__name_set:
  # Set
  mov %si, %di
  add $0x02, %si

  # CL = Name Size + Padding
  xor %cx, %cx # Init
  mov (%si), %cl # Name Size
  add 1(%si), %cl # Padding

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
  add $0x08, %si # 1 (Name Size) + 1 (Padding) + 2 (File Type) + 4 (Sector) = 8

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
# -----========== > Command (rm) ==========-----

cmd_rm:
_cmd_rm__run:
  # Remov Arg !!!!!!

  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  mov $0x8000, %si

_cmd_rm__run_loop:
  # Null ? End
  mov (%si), %al
  test %al, %al
  jz _cmd_rm__run_end

  # Init
  xor %al, %al
  mov %al, (%si)

  # Loop
  inc %si
  jmp _cmd_rm__run_loop

_cmd_rm__run_end:
  # Disk Write
  clc
  mov $0x43, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Newline
  call newline

  # Return
  ret

# -----========== < Command (rm) ==========-----

cmd_read:
  # Disk Read
  clc
  mov $0x42, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc cmd_echo_opt_err

  # Char Read
  mov $0x8000, %si
  mov $0x0E, %ah
  mov (%si), %al
  int $0x10

  # Return
  ret

# =============== < Commands ===============
# =============== > Data ===============

# Master Sector
# Next Free Sector: 4 Bytes
# Delete Sector List: 4 Bytes
# ...

# File Entry [Min: 12 Bytes - Max: 512 Bytes]
# Name: 4 - 504 Bytes
# Name Align: 1 - 2 Byte
# File Type: 2 Bytes, 0x000F: File, 0x000E: Execute, 0x000D: Directory, 0x00DE: Delete
# Sector List: 4 Bytes

# Sector List
# Data Sector: 4 Bytes
# ...

# Data Sector (Directory)
# File Entry
# ...

# Data Sector (File)
# Data
# ...

# Temporary
# Master Sector: 0x10
# DAP Start: 0x11

# =============== < Data ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
