# Fayfs
- `inode`
- `tmp_inode`
- `inum`
- `tmp_inum`

---

## Fayfs Bitmap
Fix in Fayos:
- block size [4 KiB]
- - sector [512-byte] * 8
- `hard_disk / block_size`

Block bitmap examples:
- hard\_disk [1 MiB]
- - [1 MiB] / [4 KiB] = [256-bit] = [32-byte]
- hard\_disk [4 GiB]
- - [4 GiB] / [4 KiB] = [1048576-bit] = [131072-byte] = [128-KiB]

Inode bitmap examples:
- Block bitmap size [128-KiB]
- - [128-KiB] / 8 = [16-KiB]

---

> Authors: Facooya and Fanone Facooya
