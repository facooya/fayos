# ATA read sectors
## Overview
ATA read sectors function. Trigger `isr\_ata` by irq 14 line.

---

## API Reference
#### Parameters
- ub16 \*seg
- ub16 \*off
- ub16 LBA
- ub16 sect\_cnt

#### Requires
- interrupt enable
- - `sti`

#### Modifies
- ata\_stat
- - Docs: [ata\_data](/docs/drv/ata/ata_data.md)

#### Returns
- dx:ax = seg:off

#### Internal
- isr\_ata
- - Docs: [isr\_ata](/docs/int/isr_ata.md)

---

## Process Flow
1. Save segment and offset in `ata_stat` structure
- Docs: [ata\_stat](/docs/drv/ata/ata_data.md)
2. Set drive mode
- Set drive mode is `0b11100000`. It means set master drive and using LBA mode
- - bit 3-0: 4 bit of LBA most high
- - bit 4: 0=master, 1=slave
- - bit 5,7: always 1
- - bit 6: 0=CHS, 1=LBA
3. Wait 400ns
4. Check BSY bit and RDY bit
- BSY: 0=not\_busy, 1=busy
- RDY: 0=not\_ready, 1=ready
5. Write sector conut and LBA in registers
- Sector count in `ata_stat` too
- LBA high value set 0
- - [1 Byte] lba\_lo, [1 Byte] lba\_mid
6. Disable interrupt
7. Send command for read
- Command value in `ata_stat` too
8. Wait 400ns
9. Enable interrupt
10. Start ATA interrupt handler
- Docs: [isr\_ata](/docs/int/isr_ata.md)
11. Wait for sector count 0

---

## Terms
- ATA: Advanced Technology Attachment
- LBA: Logical Block Address
- IRQ: Interrupt REquest
- ISR: Interrupt Service Routine

## Reference links
[ata\_data](/docs/drv/ata/ata_data.md)
[isr\_ata](/docs/int/isr_ata.md)
[osdev](https://wiki.osdev.org/ATA_read/write_sectors#Read_in_LBA_mode)

> Authors 2025 Facooya and Fanone Facooya
