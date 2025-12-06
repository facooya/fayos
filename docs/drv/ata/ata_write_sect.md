# ATA Write Sectors
## Overview
ATA write sectors. Data transfer mode PIO and interrupt mode. Trigger `isr_ata` by irq 14.

---

## API Reference
### Parameters
1. `ub16 *seg`
1. `ub16 *off`
1. `ub16 lba`
1. `ub16 sect_cnt`

> ub: unsinged bit

### Requires
- `sti` - interrupt enable
- clear nIEN bit in DCR - interrupt enable

### Modifies
- `ata_buf`

### Returns
- `dx:ax = seg:off`

| Description | Link |
| --- | --- |
| Definition to `ata_buf` | [docs: ata data](/docs/drv/ata/ata_data.md) |
| What is nIEN | [docs: ata nIEN](/docs/drv/ata/README.md#note-nien) |

---

## Process Flow
1. Save segment and offset in `ata_buf` structure
1. Set drive mode
    - Set master and LBA mode.
1. Wait 400ns
1. Check BSY bit and DRDY bit
    - Ready for BSY=0, DRDY=1
1. Write sector conut and LBA in registers
    - Sector count in `ata_buf` too
    - LBA high value set 0
    - - [1 Byte] lba\_lo, [1 Byte] lba\_mid
1. Send command for write
    - Command value in `ata_buf` too
1. Wait 400ns
1. Check BSY bit and DRQ bit.
    - Ready for BSY=0, DRQ=1
1. Disable interrupt - `cli`
    - Very danger work. Data segment modifiy for outsw.
1. Write 1 sector
    - `outsw` using `ds:si` registers
    - Repeat 256 times. 256:times \* 2:word = 512:bytes, 1 sector size = normal 512-byte
1. Wait 400ns
    - Must using alternate status register. If read status register do clear interrupt signal. Alternate status register read status code is same and not clear interrupt signal.
1. Offset update in `ata_buf`
1. Enable interrupt - `sti`
1. Start ATA interrupt handler (`isr_ata`)
1. Loop till sector count 0

| Description | Link |
| --- | --- |
| Definition to `ata_buf` | [docs: ata data](/docs/drv/ata/ata_data.md) |
| Why delay 400ns | [docs: ata delay 400ns](/docs/drv/ata/README.md#note-delay-400ns) |
| Interrupt handler | [docs: isr ata](/docs/int/isr_ata.md) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent Document | [docs: ata](/docs/drv/ata/README.md) |
| Definition to `ata_buf` structure | [docs: ata data](/docs/drv/ata/ata_data.md) |
| Header for ATA | [docs: inc ata](/docs/inc/drv/ata.md) |
| Interrupt handler | [docs: isr ata](/docs/int/isr_ata.md) |
| External link: Standard document | [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode) |

---

> Authors 2025 Facooya and Fanone Facooya
