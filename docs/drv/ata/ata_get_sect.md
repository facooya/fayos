# ATA Get Total Sectors
## Overview
Identify device commend and read device data and return number of total sectors. If sectors over maximum or not divided sector count per block, Limit maximum value or turncated.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `N/A`

### Returns
- `dx:ax = tot_sect_hi:tot_sect_lo`

---

## Process Flow
1. Disable interrupt using nIEN
    - delay 400ns
1. Set drive using master and LBA
    - delay 400ns
1. Check BSY bit and DRDY bit
    - ready for BSY=0, DRDY=1
1. Command for identify device
    - delay 400ns
    - ready for DRQ=1
1. Read data
    - before loop for count=0
    - if count is same total sectors offset, save total sectors value in `dx:ax`
1. Check maximum
    - if over maximum value, change total sectors value is maximum value
1. Check turncate
    - if total sectors not divided sector count per block, turncate remain
1. Enable interrupt using nIEN
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
