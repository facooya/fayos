.global _start
.code16
# =============== > Boot Start ===============

_start:
  # Facooya OS does not use IRQ in x86-16 mode
  cli # Clear Interrupt

  # Skip Init [CS,SI,DI,IP]
  # [CS]: 0x07C0, [IP]: 0x0000
  # (0x07C0 * 16) + 0x0000 = 0x7C00

  # Init [AX,DS,ES,SS]
  xor %ax, %ax
  mov %ax, %ds
  mov %ax, %es
  mov %ax, %ss

  # Init [BX,CX,DX,BP]
  mov %ax, %bx
  mov %ax, %cx
  mov %ax, %dx
  mov %ax, %bp

  # Stack Start, 0x7000 - 0x7BFF, Max: 1536 Stacks
  mov $0x7C00, %sp

  # Print
  push $_os_name_msg
  call print_msg
  add $0x02, %sp

  # Disk
  call disk_load

  # Jump Kernel, [CS]: 0x0000, [IP]: 0x1000
  ljmp $0x0000, $0x1000 # 0x1000: Kernel Address

# =============== < Boot Start ===============
# =============== > Disk ===============

disk_load:
  # Disk Read
  clc # Clear Carry Flag
  mov $0x42, %ah # Read
  mov $0x80, %dl # Hard Disk
  mov $_dap_kernel, %si # DAP
  int $0x13 # Disk Read
  jc disk_err # CF ? Error

  # Print
  push $_disk_ok_msg
  call print_msg
  add $0x02, %sp

  # Return
  ret

disk_err:
  # Print
  push $_disk_err_msg
  call print_msg
  add $0x02, %sp

  # CPU Halt
  hlt

# =============== < Disk ===============

# print_msg(msg)
# msg: Message, 0x00: Padding [1 Byte]
print_msg: # Entry Point
  push %bp
  mov %sp, %bp

  # Set
  mov 4(%bp), %si # msg set
  mov $0x0E, %ah # Print set

_print_msg__loop:
  # Null ? Done
  mov (%si), %al
  test %al, %al
  jz _print_msg__done

  # Print
  int $0x10

  # Loop
  inc %si
  jmp _print_msg__loop

_print_msg__done:
  pop %bp
  ret
# =============== > Data ===============

_os_name_msg: .asciz "\nFAYOS\r\n" # FAYOS: FAcooYa Operating System
_disk_ok_msg: .asciz "Kernel Disk Ok\r\n"
_disk_err_msg: .asciz "Kernel Disk Err\r\n"

_dap_kernel: # Disk Address Packet
  .byte 0x10 # Size
  .byte 0x00 # Reserved
  .word 0x30 # Sector Count, Kernel Size
  .word 0x1000 # Offset, REG IP, Kernel 0x1000
  .word 0x0000 # Segment, REG CS
  .word 0x20 # LBA (Low), Kernel: 0x20 - 0x4F
  .word 0x00 # LBA (High)
  .word 0x00 # Unset
  .word 0x00 # Unset

# =============== < Data ===============

# Set 512 Bytes
.fill 0x1FE-(.-_start), 0x01, 0x00 # 0x1FE (510)
.word 0xAA55 # Magic Number (Little Endian), .byte 0x55, 0xAA

# Note
# boot.img
# Boot: 0x7C00 - 0x7DFF, Kernel: 0x7E00 - (0x0200 * Sector)

# =============== < Include ===============
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
