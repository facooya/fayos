# Read Inode
Surmmary:
```
read_inode(inum_hi, inum_lo)
```

---

## Arguments
Surmmary:
- `inum` [4-byte]

Get values:
- [sp+4] `inum_hi`
- [sp+6] `inum_lo`

---

## Workflow
- read block (inode table)
- set memory (inum)
- set inode structure

---

> Authors: Facooya and Fanone Facooya
