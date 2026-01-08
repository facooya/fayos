# Bochs
## Overview
Shell script to execute Fayos in Bochs.

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
| `bochs` | `bochs [OPTIONS]` | Execute |

#### Options
| Name | Usage | Description |
| --- | --- | --- |
| `f` | `-f FILE` | Configuration file |

#### Configuration
| Name | Usage | Description |
| --- | --- | --- |
| `romimage` | `romimage: PROP` | ROM image. Set for Fayos `romimage: file=$BXSHARE/BIOS-bochs-latest`. |
| `vgaromimage` | `vgaromimage: PROP` | VGA ROM image. Set for Fayos `vgaromimage: file=$BXSHARE/VGABIOS-lgpl-latest`. |
| `ata0-master` | `ata0-master: PROP...` | ATA master. Set for Fayos `ata0-master: type=disk, path=../build/fayos.img`. |
| `boot` | `boot: TYPE` | Boot. Set for Fayos `boot: disk`. |
| `clock` | `clock: PROP...` | Set clock. Set for Fayos `clock: sync=slowdown, time0=local, rtc_sync=1`. |
| `log` | `log: FILE` | Log file. Set for Fayos `log: ../build/bochslog`. |

#### Reference Notes
| Description | Link |
| --- | --- |
| Note for Bochs | [docs: note bochs](#note-bochs) |

---

## Notes
### Note Bochs
- Q. How to install?
- A. `sudo apt install bochs bochsbios vgabios bochs-sdl`

More options `bochs --help`. And more run commands document default location `/usr/share/doc/bochs/examples/bochsrc.gz`.

---

## Terms
| Name | Description |
| --- | --- |
| BX | Bochs |
| RC | Run Commands |
| PROP | Property |
| RTC | Real Time Clock |
| ATA | Advanced Technology Attachement |
| VGA | Video Graphic Array |
| ROM | Read Only Memory |
| BIOS | Basic Input Output System |

---

## Reference Links
| Description | Link |
| --- | --- |
| Directory document for tools | [docs: tools](/docs/tools/README.md) |
| Document for build | [docs: makefile](/docs/Makefile.md) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
