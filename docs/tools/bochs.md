# Bochs
## Overview
Execute Fayos in Bochs

---

## Reference
**Commands**
| Name | Usage | Description |
| --- | --- | --- |
| `bochs` | `bochs [OPTIONS]` | Execute |

**Options**
| Name | Usage | Description |
| --- | --- | --- |
| `f` | `-f FILE` | Configuration file |

**Configuration**
| Name | Usage | Description |
| --- | --- | --- |
| `romimage` | `romimage: PROP` | ROM image. Set for Fayos `romimage: file=$BXSHARE/BIOS-bochs-latest`. |
| `vgaromimage` | `vgaromimage: PROP` | VGA ROM image. Set for Fayos `vgaromimage: file=$BXSHARE/VGABIOS-lgpl-latest`. |
| `ata0-master` | `ata0-master: PROP...` | ATA master. Set for Fayos `ata0-master: type=disk, path=../build/fayos.img`. |
| `boot` | `boot: TYPE` | Boot. Set for Fayos `boot: disk`. |
| `clock` | `clock: PROP...` | Set clock. Set for Fayos `clock: sync=slowdown, time0=local, rtc_sync=1`. |
| `log` | `log: FILE` | Log file. Set for Fayos `log: ../build/bochslog`. |

---

> Authors 2025 Facooya and Fanone Facooya
