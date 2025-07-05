# Add Dentry
Surmmary:
```
add_dentry(
  src_i_num_hi, src_i_num_lo,
  dst_i_num_hi, dst_i_num_lo,
  info (file_type:name_len),
  name_ptr
)
```

---

## Arguments
Get values:
- [sp+4] `src_i_num_hi`
- [sp+6] `src_i_num_lo`
- [sp+8] `dst_i_num_hi`
- [sp+10] `dst_i_num_lo`
- [sp+12] `info`
- [sp+14] `name_ptr`

Detail:
- `src_i_num` [4-byte]
- - [sp+4] `src_i_num_hi` [2-byte]
- - [sp+6] `src_i_num_lo` [2-byte]
- `dst_i_num` [4-byte]
- - [sp+8] `dst_i_num_hi` [2-byte]
- - [sp+10] `dst_i_num_lo` [2-byte]
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
