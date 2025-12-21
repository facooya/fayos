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

> Authors: Facooya and Fanone Facooya
