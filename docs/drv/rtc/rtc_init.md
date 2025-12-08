# RTC Initialization
## Overview
Modifiy register A and configuration register B. 24 Hours and binary and PIE enable.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `cli` - Disable interrupt

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Configuration register A
    - with NMI disable
    - keep UIP
    - set DV [32.768 kHz]
    - set RS [1024 Hz]
1. Configuration register B
    - NMI disable
    - set TF, 24H
    - set DM, binary
    - set PIE
1. Enable NMI

| Description | Link |
| --- | --- |
| Why disable NMI | [docs: rtc nmi](/docs/drv/rtc/README.md#note-nmi) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: rtc](/docs/drv/rtc/README.md) |
| External link, RTC standard document | [OSDev: rtc](https://wiki.osdev.org/RTC) |

---

> Authors 2025 Facooya and Fanone Facooya
