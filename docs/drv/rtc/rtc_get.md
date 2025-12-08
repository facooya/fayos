# RTC get date
## Overview
RTC get date using port. And save values `rtc_date`. It will excute once every day or every boot.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `cli` - Disable interrupt

### Modifies
- `rtc_date`

### Returns
- `N/A`

---

## Process Flow
1. Check UIP
    - with disable NMI
    - ready for UIP=0
1. Get date and save to `rtc_date`
    - with disable NMI
1. Enable NMI

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: rtc](/docs/drv/rtc/README.md) |
| External link, RTC standard document | [OSDev: rtc](https://wiki.osdev.org/RTC) |

---

> Authors 2025 Facooya and Fanone Facooya
