# Add Dentry
Surmmary:
```
add_dentry(
  src_inum_hi, src_inum_lo,
  dst_inum_hi, dst_inum_lo,
  info (file_type:name_len),
  name_ptr
)
```

---

## Arguments
Get values:
- [sp+4] `src_inum_hi`
- [sp+6] `src_inum_lo`
- [sp+8] `dst_inum_hi`
- [sp+10] `dst_inum_lo`
- [sp+12] `info`
- [sp+14] `name_ptr`

Detail:
- `src_inum` [4-byte]
- - [sp+4] `src_inum_hi` [2-byte]
- - [sp+6] `src_inum_lo` [2-byte]
- `dst_inum` [4-byte]
- - [sp+8] `dst_inum_hi` [2-byte]
- - [sp+10] `dst_inum_lo` [2-byte]
- [sp+12] `info` [2-byte]
- - `high=file_type` [1-byte]
- - `low=name_len` [1-byte]
- [sp+14] `name_ptr` [2-byte]

---

## Workflow
- prolog
- read inode
- set block lba

- read block
- - set memory (bx=0x8000)
- - allocate dentry (update memory)

- write in memory
- - inode number
- - information
- - record size
- - - align 4
- - init before write name
- - write name

- write block
- `if (file_type == directory)`
- - file\_size = inode\_size
- - [exten] `update_i_file_size`

- epilog

---

> Authors: Facooya and Fanone Facooya
