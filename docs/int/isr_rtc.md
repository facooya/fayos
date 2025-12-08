# Interrupt Service Routine for RTC
## Overview
Invoke by Interrupt request. Using IRQ 8 line.

---

## Interrupt Reference
### Invoke
- Every tick.

### Modifies
- `rtc_tick`
- `rtc_date`

| Description | Link |
| --- | --- |
| Definition to `rtc_tick` and `rtc_date` | [docs: kernel data](/docs/kern/kern_data.md) |

---

## Process Flow
1. Clear interrupt signal
    - with disable NMI
1. Enable NMI
1. Check initialization flag
    - If not 0, done
1. Tick is not 1024, Increase tick and done
1. Tick is 1024, Update time and zero tick

| Description | Link |
| --- | --- |
| NMI | [docs: rtc note nmi](/docs/drv/rtc/README.md#note-nmi) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: rtc](/docs/drv/rtc/README.md) |
| RTC update time | [docs: rtc update time](/docs/drv/rtc_upd_time.md) |
| External link, RTC standard document | [OSDev: rtc](https://wiki.osdev.org/RTC) |

---

> Authors 2025 Facooya and Fanone Facooya
