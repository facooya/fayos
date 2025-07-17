# Add Inode
Surmmary:
```c
// return tmp_inum
void add_inode() {
  mem = read_disk(dap_bb);
  uint16_t blknum = alloc_bit(mem);

  mem = read_disk(dap_ib);
  uint16_t inum = alloc_bit(mem);

  mem = read_disk(dap_it);
  mem += inum * I_SIZE;
  *(mem+I_BLK_0_LO_OFF) = blknum;
  write_disk(dap_it);

  mem = read_disk(dap_ib);
  inum = alloc_bit(mem);
  tmp_inum = inum; // return
  set_bit(mem, inum);
  write_disk(dap_ib);

  mem = read_disk(dap_bb);
  blknum = alloc_bit(mem);
  set_bit(mem, blknum);
  write_disk(dap_bb);
}
```

---

## Calculate Inode Table Logic
```asm
# (mem) bx = 0x8000
xor %dx, %dx
pop %ax # inum, before push
mov $I_SIZE, %cx
mul %cx # ax *= cx
add %ax, %bx # set mem
```

Examples:
```asm
xor %dx, %dx
pop %ax # inum = 0x10 (Example value)
mov $I_SIZE, %cx # I_SIZE = 0x20
```
- ax = 0x10 (Example)
- bx = 0x8000 (Example)
- cx = 0x20
- dx = 0x00

```asm
mul %cx # dx:ax *= cx
add %ax, %bx # bx += ax
```
- ax * cx = dx:ax
- - 0x10 * 0x20 = 0x0000:0x0200
- bx += ax
- - 0x8000 + 0x0200 = 0x8200

---

> Authors: Facooya and Fanone Facooya
