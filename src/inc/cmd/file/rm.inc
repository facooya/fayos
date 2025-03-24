.code16

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
  jc err_disk

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
  jc err_disk

  # Newline
  call newline

  # Return
  ret

# -----========== < Command (rm) ==========-----
# =============== > FACOOYA ===============
# Copyright 2025 Facooya.
# =============== < FACOOYA ===============
