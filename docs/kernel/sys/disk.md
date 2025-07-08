# Disk
## Index
- `_sys_read_disk`
- `_sys_write_disk`

require:
- si = &DAP

return:
- carry flag

> [!NOTE]
> DAP: Disk Address Packet

## Workflow
- clear carry flag
- set disk mode (read/write)
- set disk drive
- interrupt disk

---

> Authors: Facooya and Fanone Facooya
