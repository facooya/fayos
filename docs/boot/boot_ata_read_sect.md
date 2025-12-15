# Boot ATA Read Sectors
## Overview
Read sectors in bootloader for kernel sectors read.
Implements PIO (Programmed Input Output) mode polling method.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Set drive mode
    - set drive master and LBA mode
    - delay 400ns
1. Set sector count and LBA and send command to read
    - after send command delay 400ns
1. Data request check every sectors
1. Data read
    - if sector count 0, done

| Description | Link |
| --- | --- |
| Why delay 400ns | [docs: ata delay 400ns](/docs/drv/ata/README.md#note-delay-400ns) |

---

## Reference Links
| Description | Link |
| --- | --- |
| ATA read sectors | [docs: ata read sect](/docs/drv/ata/ata_read_sect.md) |
| Main document for boot | [docs: boot](/docs/boot/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
