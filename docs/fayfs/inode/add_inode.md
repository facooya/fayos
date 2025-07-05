# Add Inode
Surmmary:
```
add_inode(
  i_num_hi, i_num_lo,
  i_blk_num_hi, i_blk_num_lo,
  info (file_type:blk_len)
)
```

---

## Arguments
Surmmary:
- `i_num` [4-byte]
- `i_blk_num` [4-byte]
- `info` [2-byte]

Get values:
- [sp+4] `i_num_hi`
- [sp+6] `i_num_lo`
- [sp+8] `i_blk_num_hi`
- [sp+10] `i_blk_num_lo`
- [sp+12] `info`

Detail:
- `i_num` [4-byte]
- - [sp+4] `i_num_hi` [2-byte]
- - [sp+6] `i_num_lo` [2-byte]
- `i_blk_num` [4-byte]
- - [sp+8] `i_blk_num_hi` [2-byte]
- - [sp+10] `i_blk_num_lo` [2-byte]
- [sp+12] `info` [2-byte]
- - `file_type` [1-byte]
- - `blk_len` [1-byte]

---

## Workflow
- prolog
- read block (inode table)
- calculate inode table memory
- write inode table
- write block (inode table)
- epilog

### Calculate Inode Tabel Memory
```asm
# (memory) bx = 0x8000
xor %dx, %dx
mov 0x06(%bp), %cx
mov $I_SIZE, %ax
mul %cx
add %ax, %bx
```

Examples:
```asm
xor %dx, %dx
mov 0x06(%bp), %cx # i_num_lo = 0x10 (Example value)
mov $I_SIZE, %ax # I_SIZE = 0x20
```
- ax = 0x20
- bx = 0x8000 (Example)
- cx = 0x10 (Example)
- dx = 0x00

```asm
mul %cx # ax * cx = dx:ax
add %ax, %bx # bx += ax
```
- ax * cx = dx:ax
- - 0x20 * 0x10 = 0x0000:0x0200
- bx += ax
- - 0x8000 + 0x0200 = 0x8200

---

> Authors: Facooya and Fanone Facooya
