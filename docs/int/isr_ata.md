# Interrupt Secvice Routine for ATA
## Overview
Invoke by interrupt request. Using IRQ 14 line.

---

## Interrupt Reference
### Invoke
1. `ata_read_sect`
1. `ata_write_sect`

### Modifies
- `ata_buf`

| Description | Link |
| --- | --- |
| Definition to `ata_buf` | [docs: ata data](/docs/drv/ata/ata_data.md) |
| Read sectors | `/drv/ata/ata_read_sect.s` | [docs: ata read sect](/docs/drv/ata/ata_read_sect.md) |
| Write sectors | `/drv/ata/ata_write_sect.s` | [docs: ata write sect](/docs/drv/ata/ata_write_sect.md) |

---

## Process Flow
1. Clear interrupt signal by read status register
1. Decision refer to read `ata_buf` command part
    - before if set `init_flag` is Ignore interrupt signal so out this ISR

**Read**
1. Read data using `insw`
    - delay 400ns
1. Update offset in `ata_buf`
1. Minus 1 to sector count in `ata_buf`

**Write**
1. Minus 1 to sector count in `ata_buf`
    - if 0, done
1. Wait data request bit
    - ready for DRQ=1
1. Write data using `outsw`
    - delay 400ns
1. Update offset in `ata_buf`
    > [!IMPORTANT]
    > Update before restore ds register

| Description | Link |
| --- | --- |
| Why delay 400ns | [docs: ata delay 400ns](/docs/drv/ata/README.md#note-delay-400ns) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent Document | [docs: ata](/docs/drv/ata/README.md) |
| Header for ATA | [docs: inc ata](/docs/inc/drv/ata.md) |
| Read sectors | `/drv/ata/ata_read_sect.s` | [docs: ata read sect](/docs/drv/ata/ata_read_sect.md) |
| Write sectors | `/drv/ata/ata_write_sect.s` | [docs: ata write sect](/docs/drv/ata/ata_write_sect.md) |

---

> Authors 2025 Facooya and Fanone Facooya
