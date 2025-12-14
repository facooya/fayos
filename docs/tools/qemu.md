# QEMU
## Overview
Execute Fayos in QEMU.

---

## Reference
**Commands**
| Name | Usage | Description |
| --- | --- | --- |
| `qemu-system-i386` | `qemu-system-i386 [OPTIONS]` | Execute in 32 bit mode |

**Options**
| Name | Usage | Description |
| --- | --- | --- |
| `drive` | `-drive PROP...` | Set drive. Set for Fayos `-drive file=./build/fayos.img,format=raw`. |
| `rtc` | `-rtc PROP...` | Set clock. Set for Fayos `-rtc base=localtime`. |

---

> Authors 2025 Facooya and Fanone Facooya
