.code16
# =============== > Commands ===============
# -----========== > Command (touch) ==========-----

# cmd_touch()
# cmd_table => cmd_touch()
# Block Entry => Disk Read => Directory Entry => Disk Write
cmd_touch:

# ----------===== > Touch (name) =====----------

_cmd_touch__set_dap:
  # Set DAP
  push $0x00
  push $0x11 # Test
  push $0x01
  call set_dap # block.inc
  add $0x06, %sp

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
  call dentry_name_align # block.inc
  add $0x02, %sp

_cmd_touch__file_type:
  movb $0x0F, (%si) # File Type
  movb $0x00, 1(%si) # Block Level
  add $0x02, %si

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
  movw %ax, (%si)
  add $0x02, %si

  # High
  mov 2(%di), %ax
  movw %ax, (%si)
  add $0x02, %si

  # Next Sector Number
  mov (%di), %ax
  add $0x01, %ax
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
# -----========== > Command (cat) ==========-----

cmd_cat:
_cmd_cat__set_dap:
  # Set DAP
  push $0x00
  push $0x11 # Test Current Directory
  push $0x01
  call set_dap # block.inc
  add $0x06, %sp

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
  add $0x02, %si # Name Size

  xor %cx, %cx # Init
  mov (%si), %cl # Name Size
  add 1(%si), %cl # Padding

  sub %cx, %di # [DI]: File Name

  push %si # Name Size
  mov $arg_buf, %si

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

  # [SI]: Name Size
  add $0x08, %si  # [SI]: Next Name
  jmp _cmd_cat__magic_loop

_cmd_cat__cmp_name_match:
  # Print Data
  pop %si # [SI]: Memory Address, Name Size

  mov $0x0E, %ah
  mov $'M', %al
  int $0x10

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # Block Level Check
  add $0x02, %si # File Type
  mov 1(%si), %al # Block Level
  test %al, %al
  jnz _cmd_cat__done # Only Direct Block

  add $0x02, %si # Block Entry

  # set_dap(count, low, high)
  mov 2(%si), %ax
  push %ax # high
  mov (%si), %ax
  push %ax # low
  push $0x01 # count
  call set_dap # block.inc
  add $0x06, %sp
  
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
# -----========== > Command (ls) ==========-----

# Current Directory !!!
# Find Magic, Name Size, Padding, Next Magic ...
cmd_ls:

_cmd_ls__set_dap:
  # Set DAP
  push $0x00
  push $0x11 # Test
  push $0x01
  call set_dap # block.inc
  add $0x06, %sp

_cmd_ls__read:
  # Disk Read
  push $dap
  push $0x42
  call disk_rw
  add $0x04, %sp

  # Newline
  call newline

  # Ready
  mov $0x8000, %si

_cmd_ls__magic_loop:
  # Magic ? Name Set
  mov (%si), %bx
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
  mov 2(%si), %bx
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
  add $0x08, %si # 1 (Name Size) + 1 (Padding) + 2 (File Type) + 4 (Block Entry) = 8

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

# =============== < Data ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
