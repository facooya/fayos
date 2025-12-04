# ATA Write Sectors
## Overview
ATA write sectors. Data transfer mode PIO and interrupt mode. Trigger `isr_ata` by irq 14.

---

## API Reference
### Parameters
- ub16 \seg
- ub16 \off
- ub16 lba
- ub16 sect\_cnt

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
1. Wait 400ns - [docs: ata delay 400ns](/docs/drv/ata/README.md#ata-delay-400ns)
1. Check BSY bit and RDY bit
- BSY: 0=not\_busy, 1=busy
- RDY: 0=not\_ready, 1=ready
1. Write sector conut and LBA in registers
- Sector count in `ata_stat` too
- LBA high value set 0
- - [1 Byte] lba\_lo, [1 Byte] lba\_mid
1. Send command for write
- Command value in `ata_stat` too
1. Wait 400ns
1. Check BSY bit and DRQ bit.
1. Disable interrupt - `cli`
- Very danger work. data segment modifiy for outsw.
1. Write 1 sector
- `outsw` using ds:si registers
- Repeat 256 times. 256:times \* 2:word = 512:bytes, 1 sector size = normal 512-byte
1. Wait 400ns
1. Offset update in `ata_stat`
1. Enable interrupt - `sti`
1. Start ATA interrupt handler (`isr_ata`)
1. Loop till sector count 0

---

## Reference Links
- [docs: ata data](/docs/drv/ata/ata_data.md)
- [docs: isr ata](/docs/int/isr_ata.md)

### External
[osdev: ata\_write](https://wiki.osdev.org/ATA_read/write_sectors#ATA_write_sectors)

---

> Authors 2025 Facooya and Fanone Facooya
