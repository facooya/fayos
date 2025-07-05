# Lookup Dentry
Surmmary:
```
lookup_dentry(
  i_num_hi, i_num_lo
  name_len,
  name_ptr
)
```
return:
- ax = `not_match:0, match:memory`

---

## Arguments
Get values:
- [sp+4] `i_num_hi`
- [sp+6] `i_num_lo`
- [sp+8] `name_len`
- [sp+10] `name_ptr`

Detail:
- `i_num` [4-byte]
- - [sp+4] `i_num_hi` [2-byte]
- - [sp+6] `i_num_lo` [2-byte]
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
