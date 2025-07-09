# Disk Address Packet

> [!NOTE]
> DAP: Disk Address Packet
> LBA: Logical Block Address

## Index
- data:
- - `dap` (mutable LBA)
- - `dap_super` (immutable LBA and memory)
- - `dap_inode` (immutable LBA and memory)
- func:
- - `set_dap_lba`

---

## DAP Structure
### Surmmary
- [off+0] DAP size [1-byte]
- [off+1] reserved [1-byte]
- [off+2] sector count [2-byte]
- [off+4] segment:offset [4-byte]
- [off+8] LBA [8-byte]

### Detail
- [off+0] DAP size [1-byte]
- [off+1] reserved (always 0) [1-byte]
- [off+2] sector count [2-byte]
- [off+4] segment:offset [4-byte]
- - [off+4] offset [2-byte]
- - [off+6] segment [2-byte]
- [off+8] LBA [8-byte]
- - [off+8] LBA low [2-byte]
- - [off+10] LBA high [2-byte]
- - [off+12] LBA unuse in Fayos [2-byte]
- - [off+14] LBA unuse in Fayos [2-byte]

---

> Authors: Facooya and Fanone Facooya
