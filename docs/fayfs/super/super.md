# Process Superblock
## Summary
```c
#include "fayfs/sb.s"
void proc_super() {
  mem = read_disk(&dap_super);

  if (mem_sb_magic != sb_magic) {
    /* run_make */
    dp_mem = mem;
    dp_mem += DP_BUF_OFF;
    _sys_read_disk_param(); // using dp_mem

    _super_alloc_lba();
    _super_write_data();
    write_disk(&dap_super);

    _super_set_lba();
    _super_set_bitmap();

    inum = 1; // root inum
    _super_make_root();

  } else {
    /* run_init */
    inum = 1; // root inum
    _super_set_lba();
  }
}
```

Terms:
- dap: disk address packet
- dp: disk parameter
- mem: memory
- sb, super: superblock

---

## Reference
- [Superblock Structure](./README.md#superblock-structure)
- [Superblock Terms](./README.md#superblock-terms)

Functions:
- [`_super_alloc_lba()`](./_super_alloc_lba.md)

---

> Authors: Facooya and Fanone Facooya
