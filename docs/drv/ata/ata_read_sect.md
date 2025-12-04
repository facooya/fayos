# ATA Read Sectors
## Overview
ATA read sectors. Data transfer mode PIO and interrupt mode. Trigger `isr_ata` by irq 14.

---

## API Reference
### Parameters
1. ub16 \*seg
1. ub16 \*off
1. ub16 LBA
1. ub16 sect\_cnt

> ub: unsinged bit

### Requires
- interrupt enable - `sti`

### Modifies
- ata\_stat - [docs: ata data](/docs/drv/ata/ata_data.md)

### Returns
- dx:ax = seg:off

### Internal
- isr\_ata - [docs: isr ata](docs/int/isr_ata.md)

---

## Process Flow
1. Save segment and offset in `ata_stat` structure
    - [docs: ata stat](/docs/drv/ata/ata_data.md)
1. Set drive mode
    - Set drive mode is `0b11100000`. It means set master drive and using LBA mode
    - - bit 3-0: 4 bit of LBA most high
    - - bit 4: 0=master, 1=slave
    - - bit 5,7: always 1
    - - bit 6: 0=CHS, 1=LBA
1. Wait 400ns
1. Check BSY bit and RDY bit
    - BSY: 0=not\_busy, 1=busy
    - RDY: 0=not\_ready, 1=ready
1. Write sector conut and LBA in registers
    - Sector count in `ata_stat` too
    - LBA high value set 0
    - - [1 Byte] lba\_lo, [1 Byte] lba\_mid
1. Disable interrupt
1. Send command for read
    - Command value in `ata_stat` too
1. Wait 400ns
1. Enable interrupt
1. Start ATA interrupt handler - [docs: isr ata](/docs/int/isr_ata.md)
1. Loop till sector count 0

---

## Reference Links
- [docs: ata data](/docs/drv/ata/ata_data.md)
- [docs: isr ata](/docs/int/isr_ata.md)

### External
- [osdev: ata read](https://wiki.osdev.org/ATA_read/write_sectors#Read_in_LBA_mode)

---

> Authors 2025 Facooya and Fanone Facooya
