# ATA Read Sectors
## Overview
ATA read sectors. Data transfer mode PIO and interrupt mode. Trigger `isr_ata` by irq 14.

---

## API Reference
### Parameters
1. `ub16 *seg`
1. `ub16 *off`
1. `ub16 LBA`
1. `ub16 sect_cnt`

> ub: unsinged bit

### Requires
- interrupt enable - `sti`

### Modifies
- `ata_buf` - [docs: ata data](/docs/drv/ata/ata_data.md)

### Returns
- `dx:ax = seg:off`

### Internal
- `isr_ata` - [docs: isr ata](docs/int/isr_ata.md)

---

## Process Flow
1. Save segment and offset in `ata_buf` structure
    - [docs: ata buf](/docs/drv/ata/ata_data.md)
1. Set drive mode
    - Set drive, master and LBA
1. Wait 400ns
1. Check BSY bit and DRDY bit
    - Ready for BSY=0, DRDY=1
1. Write sector conut and LBA in registers
    - Sector count in `ata_buf` too
    - LBA high value set 0
    - - [1 Byte] lba\_lo, [1 Byte] lba\_mid
1. Disable interrupt
1. Send command for read
    - Command value in `ata_buf` too
1. Wait 400ns
1. Enable interrupt
1. Start ATA interrupt handler - [docs: isr ata](/docs/int/isr_ata.md)
1. Loop till sector count 0

---

## Reference Links
- [docs: ata](/docs/drv/ata/README.md)
- [docs: ata write sect](/docs/drv/ata/ata_write_sect.md)
- [docs: ata get sect](/docs/drv/ata/ata_get_sect.md)
- [docs: ata data](/docs/drv/ata/ata_data.md)
- [docs: inc ata](/docs/inc/drv/ata.md)
- [docs: isr ata](/docs/int/isr_ata.md)

### External
- [OSDev: ATA PIO Mode](https://wiki.osdev.org/ATA_PIO_Mode)

---

> Authors 2025 Facooya and Fanone Facooya
