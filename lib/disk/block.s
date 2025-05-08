# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Block read/write (docs/lib/block.txt)

# TEXT
.section .text
.code16

.global read_block
.global write_block

# ENTRY
# read_block()
read_block:
  push %si

  call sys_read_disk
  jc .hdl_disk_err

  jmp .rw_block__done

# ENTRY
# write_block()
write_block:
  push %si

  call sys_write_disk
  jc .hdl_disk_err

  jmp .rw_block__done

# DONE
.rw_block__done:
  pop %si
  ret

# ERR
.hdl_disk_err:
  call outnl
  call hdl_disk_err
  jmp .rw_block__done
