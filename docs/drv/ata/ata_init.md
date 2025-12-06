# ATA Initialization
## Overview
Interrupt enable. Clear nIEN (Negative Interrupt Enable) bit in DCR (Device Control Register).

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
1. Enable interrupt using nIEN bit
    - delay 400ns

| Description | Link |
| --- | --- |
| Why using nIEN | [docs: ata nIEN](/docs/drv/ata/README.md#note-nien) |
| Why delay 400ns | [docs: ata delay 400ns](/docs/drv/ata/README.md#note-delay-400ns) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: ata](/docs/drv/ata/README.md) |
| External link: standard document | [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode) |

---

> Authors 2025 Facooya and Fanone Facooya
