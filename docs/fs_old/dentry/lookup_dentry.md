# Lookup Dentry
Surmmary:
```
uint16_t lookup_dentry(
  uint16_t *inum,
  uint16_t name_len,
  uint16_t *name
) {
  read_inode(inum, inode);
  set_dap_blk_lba(inode);
  mem = read_disk(dap);

  while (1) {
    uint16_t dst_name_len = *(mem+DE_NAME_LEN_OFF);
    if (dst_name_len == 0) ? return 0;

    if (name_len == dst_name_len || *(mem+DE_INUM_OFF) != 0) {
      uint16_t dst_name = mem+DE_NAME_OFF;
      if (strncmp(name, dst_name, name_len)) {
        return mem; // match
      }
    }

    uint16_t file_size = *(inode+I_FILE_SIZE_OFF);
    mem += *(mem+DE_REC_LEN_OFF);
    uint16_t cpy_mem = mem;
    cpy_mem -= 0x8000;
    if (cpy_mem >= file_size) ? return 0; // no match
  }
}
```

return:
- ax = `not_match:0, match:memory`

---

> Authors: Facooya and Fanone Facooya
