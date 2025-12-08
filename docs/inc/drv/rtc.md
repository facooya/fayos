# Header for RTC
## Overview
Definition for Real Tiem Clock.

> [!IMPORTANT]
> This document write for Fayos.
> So it is different to standard.

> [!NOTE]
> **You can find standard ATA hardware reference here** [OSDev: rtc](https://wiki.osdev.org/RTC)

---

## Constants
**PORT**
| Name | Description |
| --- | --- |
| `RTC_PORT_ADDR` | Address port |
| `RTC_PORT_DATA` | Data port |

**Address**
| Name | Description |
| --- | --- |
| `RTC_ADDR_REG_A` | Address for register A |
| `RTC_ADDR_REG_B` | Address for register B |
| `RTC_ADDR_REG_C` | Address for register C |
| `RTC_ADDR_REG_D` | Address for register D |
| `RTC_ADDR_SEC` | Address for second |
| `RTC_ADDR_MIN` | Address for minute |
| `RTC_ADDR_HOUR` | Address for hour |
| `RTC_ADDR_WEEK` | Address for day of week |
| `RTC_ADDR_DAY` | Address for day of month |
| `RTC_ADDR_MONTH` | Address for month |
| `RTC_ADDR_YEAR` | Address for year|
| `RTC_NMI` | NMI bit |

**Register**
| Name | Description |
| --- | --- |
| `RTC_REG_A_UIP` | Update in progress bit |
| `RTC_REG_A_DV` | Divider value |
| `RTC_REG_A_RS` | Rate selector value |
| `RTC_REG_B_TF` | Time format bit |
| `RTC_REG_B_DM` | Data mode bit |
| `RTC_REG_B_PIE` | Periodic interrupt enable bit |

**rtc date**
| Name | Description |
| --- | --- |
| `RTC_DATE_SEC` | Second offset for `rtc_date` |
| `RTC_DATE_MIN` | Minute offset for `rtc_date` |
| `RTC_DATE_HOUR` | Hour offset for `rtc_date` |
| `RTC_DATE_WEEK` | Day of week offset for `rtc_date` |
| `RTC_DATE_DAY` | Day of month offset for `rtc_date` |
| `RTC_DATE_MONTH` | Month offset for `rtc_date` |
| `RTC_DATE_YEAR` | Year offset for `rtc_date` |

---

## Reference Links
| Description | Link |
| --- | --- |
| Parent document | [docs: rtc](/docs/drv/rtc/README.md) |
| Register Map | [docs: rtc register map](/docs/drv/rtc/README.md#register-map) |
| External link, RTC standard document | [OSDev: rtc](https://wiki.osdev.org/RTC) |

---

> Authors 2025 Facooya and Fanone Facooya
