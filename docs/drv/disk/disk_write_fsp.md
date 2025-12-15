# Disk Write FSP
## Overview
Write disk refer from FSP (File System Packet) data.

---

## API Reference
### Parameters
1. `fsp *src`

### Requires
- `ata_write_sect()`

### Modifies
- `N/A`

### Returns
- `dx:ax = seg:off`

---

## Process Flow
1. Write disk refer from FSP.
    - using `ata_write_sect()`

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for Disk | [docs: disk](/docs/drv/disk/README.md) |
| ATA write sectors | [docs: ata write sect](/docs/drv/ata/ata_write_sect.md) |
| File System Packet | [docs: fs data](/docs/fs/fs_data.md) |

---

> Authors 2025 Facooya and Fanone Facooya
