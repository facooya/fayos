# Read Inode
Surmmary:
```
read_inode(i_num_hi, i_num_lo)
```

---

## Arguments
Surmmary:
- `i_num` [4-byte]

Get values:
- [sp+4] `i_num_hi`
- [sp+6] `i_num_lo`

---

## Workflow
- read block (inode table)
- set memory (inum)
- set inode structure

---

> Authors: Facooya and Fanone Facooya
