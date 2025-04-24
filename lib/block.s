# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Block read/write and DAP setup (docs/lib/block.txt)

.code16
.section .text

.global set_dap_lba
.global set_dap_target
.global reset_dap_target
.global read_block
.global write_block
.global dap

# set_dap_lba(lba_high, lba_low) [n_set_dap]
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

# read_block()
read_block:
  push %si

  call sys_read_disk
  jc .rw_block__err

  jmp .rw_block__done

# write_block() !!! TMP
write_block:
  push %si

  call sys_write_disk
  jc .rw_block__err

  jmp .rw_block__done

# DONE
.rw_block__done:
  pop %si
  ret

# ERR
.rw_block__err:
  call outnl

  push $.block_err_msg
  call puts
  add $0x02, %sp

  call outnl

  jmp .rw_block__done

# DATA
.section .data

# dap [n_dap]
dap:
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
.block_err_msg: .asciz "Block error."
