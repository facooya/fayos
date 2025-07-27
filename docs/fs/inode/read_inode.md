# Read Inode
Surmmary:
```
void read_inode(uint16_t *inum, uint16_t *inode) {
  mem = read_disk(dap_it);

  uint16_t inode_pos = (*inum) * I_SIZE;
  mem += inode_pos;

  *(inode+I_FILE_SIZE_OFF) = *(mem+I_FILE_SIZE_OFF);
  *(inode+I_BLK_0_OFF) = *(mem+I_BLK_0_OFF);
}
```

---

> Authors: Facooya and Fanone Facooya
