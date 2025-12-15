# Disk Set DPI
## Overview
Set DPI (Disk Packet Immutable) for read/write disk DPI functions. Set DPI refer superblock.

---

## API Reference
### Parameters
- `N/A`

### Requires
- superblock already have DPI information.

### Modifies
- `dpi`

### Returns
- `N/A`

---

## Process Flow
1. Set superblock memory
1. Set DPI refer superblock
    - set order: superblock, block bitmap, inum bitmap, inode table

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for Disk | [docs: disk](/docs/drv/disk/README.md) |
| DPI information in superblock | [docs: sb write dpi](/docs/fs/sb/sb_write_dpi.md) |

---

> Authors 2025 Facooya and Fanone Facooya
