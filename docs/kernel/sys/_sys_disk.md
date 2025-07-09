# System Disk
## Index
- `_sys_read_disk`
- - require: si = &DAP
- - return: carry flag
- `_sys_write_disk`
- - require: si = &DAP
- - return: carry flag
- `_sys_read_disk_param`
- - require: si = memory for write parameter
- - return: carry flag

> [!NOTE]
> DAP: Disk Address Packet

---

## Workflow
### \*\_disk
- clear carry flag
- set disk mode (read/write)
- set disk drive
- interrupt disk

### \_sys\_read\_disk\_param
- clear carry flag
- init ax, ds
- set param buffer size
- set disk mode
- set disk drive
- interrupt disk

---

> Authors: Facooya and Fanone Facooya
