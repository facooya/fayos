# Lookup Dentry
Surmmary:
```
lookup_dentry(
  inum_hi, inum_lo
  name_len,
  name_ptr
)
```
return:
- ax = `not_match:0, match:memory`
- TODO: (available) dx = `true:1, false:0`
- - Matched name, But already removed file name.
- - if avaliable, use return memory.

---

## Arguments
Get values:
- [sp+4] `inum_hi`
- [sp+6] `inum_lo`
- [sp+8] `name_len`
- [sp+10] `name_ptr`

Detail:
- `inum` [4-byte]
- - [sp+4] `inum_hi` [2-byte]
- - [sp+6] `inum_lo` [2-byte]
- [sp+8] `name_len` [2-byte]
- [sp+10] `name_ptr` [2-byte]

---

## Workflow
Surmmary:
- prolog
- read block
- loop
- - compare length
- - compare string
- done
- epilog

---

> Authors: Facooya and Fanone Facooya
