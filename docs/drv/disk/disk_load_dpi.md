# Disk Load DPI
## Overview
Disk load memory for fast access in DPI (Disk Packet Immutable).
DPI in superblock, block bitmap, inum bitmap, inode table.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `dpi`
- `disk_read_dpi()`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Disk read DPI for memroy load
    - order: superblock, block bitmap, inum bitmap, inode table

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for Disk | [docs: disk](/docs/drv/disk/README.md) |
| Read DPI | [docs: disk read dpi](/docs/drv/disk/disk_read_dpi.md) |
| Set DPI | [docs: disk set dpi](/docs/drv/disk/disk_set_dpi.md) |
| DPI information in superblock | [docs: sb write dpi](/docs/fs/sb/sb_write_dpi.md) |

---

> Authors 2025 Facooya and Fanone Facooya
