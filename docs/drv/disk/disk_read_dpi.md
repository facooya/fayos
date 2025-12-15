# Disk Read DPI
## Overview
Read disk refer from DPI (Disk Packet Immutable) data.

---

## API Reference
### Parameters
1. `dpi *src`

### Requires
- `ata_read_sect()`

### Modifies
- `N/A`

### Returns
- `dx:ax = seg:off`

---

## Process Flow
1. Read disk refer from DPI data.

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for Disk | [docs: disk](/docs/drv/disk/README.md) |
| ATA read sectors | [docs: ata read sect](/docs/drv/ata/ata_read_sect.md) |

---

> Authors 2025 Facooya and Fanone Facooya
