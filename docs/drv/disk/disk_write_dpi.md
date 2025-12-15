# Disk Write DPI
## Overview
Write disk refer from DPI (Disk Packet Immutable) data.

---

## API Reference
### Parameters
1. `dpi *src`

### Requires
- `ata_write_sect()`

### Modifies
- `N/A`

### Returns
- `dx:ax = seg:off`

---

## Process Flow
1. Write disk refer from DPI data.
    - Using `ata_write_sect()`

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for Disk | [docs: disk](/docs/drv/disk/README.md) |
| ATA write sectors | [docs: ata write sect](/docs/drv/ata/ata_write_sect.md) |

---

> Authors 2025 Facooya and Fanone Facooya
