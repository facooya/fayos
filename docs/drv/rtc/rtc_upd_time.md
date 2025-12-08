# RTC update time
## Overview
Update time every seconds, Depend `isr_rtc`.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `isr_rtc`

### Modifies
- `rtc_date`

### Returns
- `N/A`

---

## Process Flow
1. Concatenate update.
    - if second less than 60 stop
    - if minute less than 60 stop
    - if hour less than 24 stop

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: rtc](/docs/drv/rtc/README.md) |
| ISR RTC | [docs: isr rtc](/docs/int/isr_rtc.md) |
| External link, RTC standard document | [OSDev: rtc](https://wiki.osdev.org/RTC) |

---

> Authors 2025 Facooya and Fanone Facooya
