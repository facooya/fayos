# Clear Inode
Summary:
```c
void clear_inode(uint16_t *inum) {
  mem = read_disk(dap_it);
  uint32_t calc = I_SIZE * (*inum);
  mem += calc;

  uint32_t *blknum = *(mem+I_BLK_OFF); // backup
  *(mem+I_BLK_OFF) = 0;
  write_disk(dap_it);

  mem = read_disk(dap_bb); // bb: block bitmap
  clear_bit(mem, blknum);
  write_disk(dap_bb);

  mem = read_disk(dap_ib); // ib: inum bitmap
  clear_bit(mem, inum);
  write_disk(dap_ib);
}
```

---

> Authors: Facooya and Fanone Facooya
