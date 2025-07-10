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

## Allocate LBA
Formula:
```c
total_block = hard_disk_size / block_size
block_bitmap_size = total_block / 8

total_inum = total_block / rate_inum
inum_bitmap_size = total_inum / 8

total_inode_size = total_inum * inode_size

block_bitmap_size:inum_bitmap_size:total_inode_size = 4:1:256
```

Examples:
```c
/* Immutable in Fayfs */
rate_inum = 4 // Allocate block count per inum
block_size = 4096 // 4 KiB
inode_size = 32 // 32 Bytes

/* --- Example: 1 MiB --- */
hard_disk_size = 1048576 // 1 MiB

/* 1048576 / 4096 = 256 */
total_block = 256

/* 256 / 8 = 32 (bit to byte) */
block_bitmap_size = 32

/* 256 / 4 = 64 */
total_inum = 64

/* 64 / 8 = 8 (bit to byte) */
inum_bitmap_size = 8
 
/* 64 * 32 = 2048 */
total_inode_size = 2048

/* Allocate LBA
block_bitmap_size = 32 (1 block (1 sector)) LBA: 0x00
inum_bitmap_size = 8 (1 block (1 sector)) LBA: 0x08
total_inode_size = 2048 (1 block (4 sectors)) LBA: 0x10
Normal LBA Start: 0x18
*/

/* --- Example: 1 GiB --- */
hard_disk_size = 1073741824 // 1 GiB

/* 1073741824 / 4096 = 262144 */
total_block = 262144

/* 262144 / 8 = 32768 (bit to byte) */
block_bitmap_size = 32768 // 32 KiB

/* 262144 / 4 = 65536 */
total_inum = 65536

/* 65536 / 8 = 8192 (bit to byte) */
inum_bitmap_size = 8192 // 8 KiB
 
/* 65536 * 32 = 2097152 */
total_inode_size = 2097152 // 2 MiB

/* Allocate LBA
block_bitmap_size = 32 KiB (8 blocks) LBA: 0x00-0x3F
inum_bitmap_size = 8 KiB (2 blocks) LBA: 0x40-0x4F
total_inode_size = 2 MiB (512 blocks) LBA: 0x50-024F
Normal LBA Start: 0x0250
*/
```

Summary:
rate is `4:1:256 = 1:0.25:64`, just get block bitmap size.
```
block_bitmap_size = 4
inum_bitmap_size = block_bitmap_size / 4
total_inode_size = block_bitmap_size * 64
```

---

> Authors: Facooya and Fanone Facooya
