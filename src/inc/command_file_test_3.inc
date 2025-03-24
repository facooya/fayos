.code16
# =============== > Commands ===============
# -----========== > Command (touch) ==========-----

# cmd_touch()
# cmd_table => cmd_touch()
# sector => entry => mem => run
cmd_touch:
  jmp _cmd_touch__set_dap # Test
# !!!!!!!!!!!!!!!!!!!!
_cmd_touch__st: # ST: Sector Table
  # Set DAP
  push $0x00
  push $0x11 # Test
  push $0x01
  call set_dap
  add $0x06, %sp

  # Disk Read
  push $0x42
  call disk_rw
  add $0x02, %sp

  # Set SI (Set Memory, File Entry)
  mov $0x8000, %si
  mov $0x20, %cx

_cmd_touch__st_loop:
  # Null ? End
  movw (%si), %ax
  test %ax, %ax
  jz _cmd_touch__st_end

  # Loop
  add $0x02, %si
  inc %cx
  jmp _cmd_touch__st_loop

_cmd_touch__st_end:
  # Sector Table
  mov %si, %bx
  movw %cx, (%bx)

  # Disk Write
  clc
  mov $0x43, %ah
  mov $dap, %si
  mov $0x80, %dl
  int $0x13
  jc disk_err

# ----------===== > Touch (name) =====----------
# NEW !!!!! ====================================
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
  # Null ? End
  add $0x02, %si
  movw (%si), %ax
  test %ax, %ax
  jz _cmd_touch__find_free_end

  # Loop
  add $0x02, %si
  jmp _cmd_touch__find_free_loop

_cmd_touch__find_free_end:
  sub $0x02, %si # Restore

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

_cmd_touch__magic_num:
  movw $0xFADE, (%si)
  add $0x02, %si

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

  jmp _cmd_touch__write

# < NEW !!!!! ====================================
# ----------===== < Touch (name) =====----------
# ----------===== > Touch (dentry) =====----------

# dentry: Directory Entry
_cmd_touch__dentry_set_dap:
  # Set DAP
  push $0x00
  push $0x11 # Test
  push $0x01
  call set_dap # sector.inc
  add $0x06, %sp

_cmd_touch__dentry_disk_read:
  # Disk Read
  push $0x42
  call disk_rw # sector.inc
  add $0x02, %sp

_cmd_touch__set_mem:
  # Set SI (Set Memory)
  mov $0x8000, %si
  mov %si, %bx

_cmd_touch__dentry_loop_set:
  mov %bx, %si
  mov $0x00, %cx

_cmd_touch__dentry_loop:
  # Null ? End
  movw (%si), %ax
  test %ax, %ax
  jz _cmd_touch__dentry_null_loop

  # Loop (Align [4 Bytes])
  add $0x04, %si
  mov %si, %bx
  jmp _cmd_touch__dentry_loop

_cmd_touch__dentry_null_loop:
  # CX=2 ? Loop End
  inc %cx
  cmp $0x02, %cx
  jz _cmd_touch__dentry_loop_end

  # Null ? Loop
  add $0x02, %si
  movw (%si), %ax
  test %ax, %ax
  jz _cmd_touch__dentry_null_loop

  # Return Loop
  add $0x04, %bx
  jmp _cmd_touch__dentry_loop_set

_cmd_touch__dentry_loop_end:
  mov %bx, %si

_cmd_touch__dentry_name:
  mov $arg_buf, %di
  mov $0x00, %cx

_cmd_touch__dentry_name_loop:
  # Null ? Name End
  mov (%di), %al
  test %al, %al
  jz _cmd_touch__dentry_name_end

  # Memory Write
  mov %al, (%si)

  # Loop
  inc %di
  inc %si
  inc %cx
  jmp _cmd_touch__dentry_name_loop

_cmd_touch__dentry_name_end:
  # !!!!!!!!!!!!!!!
  # cmp $0x04, %cx # Name Grater than [4 Bytes] AND Add Align

_cmd_touch__dentry_write:
  # Name Align
  inc %si

  # File Type
  mov $0x0F, %ax
  movw %ax, (%si)
  add $0x02, %si

  # Sector List !!!!!!!!!!!!!!
  mov $0x5678, %ax # Low
  movw %ax, (%si)
  add $0x02, %si

  mov $0x1234, %ax # High
  movw %ax, (%si)
  add $0x02, %si

# ----------===== < Touch (dentry) =====----------

_cmd_touch__write:
  push $0x43
  call disk_rw # sector.inc
  add $0x02, %sp

  call newline

_cmd_touch__done:
  ret

# -----========== < Command (touch) ==========-----
# -----========== > Command (ls) ==========-----

cmd_ls:
_cmd_ls__run:
  # Current Directory !!!

  # LBA 0x11 Test !!!
  # Disk Read
  push $0x42
  call disk_rw
  add $0x02, %sp

  # Newline
  call newline

  # Ready
  mov $0x8000, %si
  mov $0x0E, %ah

_cmd_ls__run_loop:
  # Null ? End
  mov (%si), %al
  test %al, %al
  jz _cmd_ls__run_loop_end

  # Print
  int $0x10

  # Loop
  inc %si
  jmp _cmd_ls__run_loop

_cmd_ls__run_loop_end:
  # Next
  add $0x08, %si

  # Space Add
  mov $0x20, %al
  int $0x10
  int $0x10

  # !Null ? Loop
  mov (%si), %al
  test %al, %al
  jnz _cmd_ls__run_loop

  # Newline
  call newline

  # Return
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
