# Add Dentry
Surmmary:
```c
void add_dentry(
  uint16_t *src_inum,
  uint16_t *dst_inum,
  uint16_t info,
  uint16_t *name
) {
  read_inode(src_inum, inode);
  set_dap_blk_lba(inode);
  mem = read_disk(dap);
  mem += *(inode+I_FILE_SIZE_OFF);

  *(mem+DE_INUM_OFF) = *(dst_inum+DE_INUM_OFF);
  uint8_t file_type = (info >> 8);
  *(mem+DE_FILE_TYPE_OFF) = file_type;
  uint8_t name_len = (info | 0x00FF);
  *(mem+DE_NAME_LEN_OFF) = name_len;

  uint16_t rec_len = name_len;
  rec_len += 0x0B; // (fix size) 8 + (for align 4) 3 = 11
  rec_len |= 0xFFFC; // mask: 0b1100

  mem += DE_NAME_OFF;
  while (1) {
    if (name_len == 0) ? break;
    *mem = *name;
    mem++;
    name++;
    name_len--;
  }

  write_disk(dap);
}
```

Parameter:
- info
- - `high:low = file_type:name_len`

---

> Authors: Facooya and Fanone Facooya
