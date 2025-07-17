# Index Node
## Inode Structure
Inode size = 0x20 [32-byte]
- [off+0] file size [2-byte]
- [off+2] information [2-byte]
- - [off+2] file type [1-byte]
- - [off+3] block length [1-byte]
- [off+4] block array [28-byte]
- - [off+4] block number 1 [4-byte]
- - [off+8] block number 2 [4-byte]
- - [off+12] block number 3 [4-byte]
- - [off+16] block number 4 [4-byte]
- - [off+20] block number 5 [4-byte]
- - [off+24] block number 6 [4-byte]
- - [off+28] block array pointer [4-byte]

block array pointer [4KiB] = capacity block count (1024)

---

> Authors: Facooya and Fanone Facooya
