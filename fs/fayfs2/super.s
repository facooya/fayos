# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Super block, LBA [2-3]

.include "fayfs/sb.s"

# TEXT
.section .text
.code16

.global read_sb
.global write_sb
.global init_sb

# ENTRY
# read_sb()
read_sb:
  # prol
  push %bx

  # read sb
  call .set_sb_lba
  call read_block
  mov $0x8000, %bx

  # i_num !!! FIXME
  # mov ROOT_I_NUM_LO_OFF(%bx), %ax
  # mov %ax, (i_num)
  # mov ROOT_I_NUM_HI_OFF(%bx), %ax
  # mov %ax, (i_num+0x02)

  # next_i_num and i_num
  mov NEXT_I_NUM_LO_OFF(%bx), %ax
  mov %ax, (next_i_num)
  mov %ax, (i_num)
  mov NEXT_I_NUM_HI_OFF(%bx), %ax
  mov %ax, (next_i_num+0x02)
  mov %ax, (i_num+0x02)

  # next_i_blk and i_blk
  mov NEXT_I_BLK_LO_OFF(%bx), %ax
  mov %ax, (next_i_blk)
  mov %ax, (i_blk)
  mov NEXT_I_BLK_HI_OFF(%bx), %ax
  mov %ax, (next_i_blk+0x02)
  mov %ax, (i_blk+0x02)

  # reset
  call reset_dap_target

  # epil
  pop %bx
  ret

# ENTRY
# write_sb()
write_sb:
  ret

# ENTRY
# init_sb()
init_sb:
  # prol
  push %bx

  # read sb
  call .set_sb_lba
  call read_block
  mov $0x8000, %bx

  # cond: != ? ne
  mov SB_MAG_LO_OFF(%bx), %ax
  cmp $SB_MAG_LO, %ax
  jne .init_sb__mag_ne

  # cond: != ? ne
  mov SB_MAG_HI_OFF(%bx), %ax
  cmp $SB_MAG_HI, %ax
  jne .init_sb__mag_ne

  # done
  call reset_dap_target
  jmp .init_sb__done

.init_sb__mag_ne:
  # set sb
  call .init_sb__set

  call write_block
  call reset_dap_target

.init_sb__done:
  # read sb
  call read_sb

  # !!! FIXME add root dir

  # epil
  pop %bx
  ret

# .ENTRY
# .init_sb__set()
.init_sb__set:
  # magic
  mov $SB_MAG_LO, %ax
  mov %ax, SB_MAG_LO_OFF(%bx)
  mov $SB_MAG_HI, %ax
  mov %ax, SB_MAG_HI_OFF(%bx)

  # sb lba
  mov $SB_LBA_LO, %ax
  mov %ax, SB_LBA_LO_OFF(%bx)
  mov $SB_LBA_HI, %ax
  mov %ax, SB_LBA_HI_OFF(%bx)

  # i tbl lba
  mov $I_LBA_LO, %ax
  mov %ax, I_LBA_LO_OFF(%bx)
  mov $I_LBA_HI, %ax
  mov %ax, I_LBA_HI_OFF(%bx)

  # root i num
  mov $ROOT_I_NUM_LO, %ax
  mov %ax, ROOT_I_NUM_LO_OFF(%bx)
  mov $ROOT_I_NUM_HI, %ax
  mov %ax, ROOT_I_NUM_HI_OFF(%bx)

  # fst lba
  mov $FST_LBA_LO, %ax
  mov %ax, FST_LBA_LO_OFF(%bx)
  mov $FST_LBA_HI, %ax
  mov %ax, FST_LBA_HI_OFF(%bx)

  # fst i num
  mov $FST_I_NUM_LO, %ax
  mov %ax, FST_I_NUM_LO_OFF(%bx)
  mov $FST_I_NUM_HI, %ax
  mov %ax, FST_I_NUM_HI_OFF(%bx)

  # fst i blk
  mov $FST_I_BLK_LO, %ax
  mov %ax, FST_I_BLK_LO_OFF(%bx)
  mov $FST_I_BLK_HI, %ax
  mov %ax, FST_I_BLK_HI_OFF(%bx)

  # i size
  mov $I_SIZE, %ax
  mov %ax, I_SIZE_OFF(%bx)

  # next i num
  mov $NEXT_I_NUM_LO, %ax
  mov %ax, NEXT_I_NUM_LO_OFF(%bx)
  mov $NEXT_I_NUM_HI, %ax
  mov %ax, NEXT_I_NUM_HI_OFF(%bx)

  # next blk num
  mov $NEXT_I_BLK_LO, %ax
  mov %ax, NEXT_I_BLK_LO_OFF(%bx)
  mov $NEXT_I_BLK_HI, %ax
  mov %ax, NEXT_I_BLK_HI_OFF(%bx)
  ret

# .ENTRY
# .set_sb_lba()
.set_sb_lba:
  # set target
  push $0x8000
  push $0x00
  push $0x02
  call set_dap_target
  add $0x06, %sp

  # set lba
  push $SB_LBA_LO
  push $SB_LBA_HI
  call set_dap_lba
  add $0x04, %sp
  ret
