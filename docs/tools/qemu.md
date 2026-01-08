# QEMU
## Overview
Shell script to execute Fayos in QEMU.

---

## Table of Contents
- [Reference](#reference)
- [Notes](#notes)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Reference
#### Commands
| Name | Usage | Description |
| --- | --- | --- |
| `qemu-system-i386` | `qemu-system-i386 [OPTIONS]` | Execute in 32 bit mode |

#### Options
| Name | Usage | Description |
| --- | --- | --- |
| `drive` | `-drive PROP...` | Set drive. Set for Fayos `-drive file=./build/fayos.img,format=raw`. |
| `rtc` | `-rtc PROP...` | Set clock. Set for Fayos `-rtc base=localtime`. |

#### Reference Notes
| Description | Link |
| --- | --- |
| Note for QEMU | [docs: note qemu](#note-qemu) |

---

## Notes
### Note QEMU
- Q. How to install?
- A. `sudo apt install qemu-system`

More options `qemu-system-i386 --help`.

---

## Terms
| Name | Description |
| --- | --- |
| QEMU | Quick Emulator |
| PROP | Property |
| RTC | Real Time Clock |

---

## Reference Links
| Description | Link |
| --- | --- |
| Directory document for tools | [docs: tools](/docs/tools/README.md) |
| Document for build | [docs: makefile](/docs/Makefile.md) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
