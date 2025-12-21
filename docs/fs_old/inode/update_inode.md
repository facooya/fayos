# Update Inode
Summary:
```c
void update_inode(uint16_t *inum, uint16_t *inode) {
  mem = read_disk(dap_it);
  mem += (*inum) * I_SIZE;

  *(mem+I_FILE_SIZE_OFF) = *(inode+I_FILE_SIZE_OFF);
  *(mem+I_BLK_0_OFF) = *(inode+I_BLK_0_OFF);

  write_disk(dap_it);
}
```

---

> Authors: Facooya and Fanone Facooya
