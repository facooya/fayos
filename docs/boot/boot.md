# Boot
## Overview
Bootloader main for Fayos.
Display contol with direct VGA access memory.
Kernel sectors read with ATA PIO mode polling method.
Write the boot signature via linker script.

---

## Table of Contents
- [Function Reference](#function-reference)
- - [`_start`](#_start)
- - [`_vga_clr`](#_vga_clr)
- - [`_vga_puts`](#_vga_puts)
- - [`_ata_read`](#_ata_read)
- [Reference Links](#reference-links)

---

## Function Reference
### `_start`
#### Overview
Boot entry point.

#### Parameters
- `N/A`

#### Requires
- `N/A`

#### Modifies
- `N/A`

#### Returns
- `N/A`

#### Process Flow
```mermaid
graph TD
Init([Initialization])
Init --> Stack[Set stack pointer]
Stack --> VGA_Clear[[_vga_clr]]
VGA_Clear --> VGA_Puts[[_vga_puts]]
VGA_Puts --> KernelMemory[Set memory for kernel]
KernelMemory --> ATA_Read[[_ata_read]]
ATA_Read --> JumpKernel([Jump to kernel memory])
```

#### Implementation
- Initialization
    - Clear interrupt and clear direction
    - init registers: `ax, ds, es, ss, sp, bp`
    - mandatory to zero: `ds, ss`
- Set stack pointer
    - `sp = 0x7C00`
- Jump to kernel
    - `cs:ip = 0x0000:0x1000`

| Description | Link |
| --- | --- |
| Clear interrupt | [docs: cli](/docs/boot/README.md#note-clear-interrupt) |
| Clear Direction | [docs: cld](/docs/boot/README.md#note-clear-direction) |
| Stack work | [docs: stack](/docs/boot/README.md#note-stack) |

---

### `_vga_clr`
#### Overview
Clear screen.

#### Parameters
- `N/A`

#### Requires
- `N/A`

#### Modifies
- `N/A`

#### Returns
- `N/A`

#### Process Flow
```mermaid
graph TD
Init([Set VGA memroy])
Init --> GetRowCol[Get screen row count and column count]
GetRowCol --> CalcSize[Calculate screen size]
CalcSize --> ClearCheck{"(screen_size == 0)?"}
ClearCheck -- Yes --> End([Set cursor to zero])
ClearCheck -- No --> Loop[Clear: Overwirte space with color attribute] -- "&vga_memory+=2, screen_size--" --> ClearCheck
```

#### Implementation
- Overwirte space to clear
- Default color attribute: background=black, foreground=lightgray
- `screen_size = row_count * column_count`
    - `row_count = row_last_index + 1`

---

### `_vga_puts`
#### Overview
Put string in VGA.

#### Parameters
1. `ub8 *str`

#### Requires
- `N/A`

#### Modifies
- `N/A`

#### Returns
- `N/A`

#### Process Flow
```mermaid
graph TD
Init([Set VGA memroy])
Init --> GetCurs[Get current cursor position]
GetCurs --> SetVGA[Set current cursor position in VGA memory]
ChrNull{"(chr == null)?"}
ChrNL{"(chr == newline)?"}
NL[Get column count]
Out[Output character]
SetVGA --> ChrNull -- Yes --> End
ChrNull -- No --> ChrNL -- Yes --> NL
ChrNL -- No --> Out
Out -- "curs_pos++, &str++, &vga_mem+=2" --> ChrNull
NL --> CR[Carriage return] --> UpdateVGA[Update VGA memory pointer refer column count] --> UpdateCurs[Update cursor position refer VGA memory pointer] -- "&str++" --> ChrNull
End([Set cursor to last index from string])
```

#### Implementation
- Default color attribute: background=black, foreground=lightgray

---

### `_ata_read`
#### Overview
Read sectors for kernel. Implements PIO mode, polling method.

#### Parameters
- `N/A`

#### Requires
- `N/A`

#### Modifies
- `N/A`

#### Returns
- `N/A`

#### Process Flow
```mermaid
graph TD
Start([Set drive mode])
Start -- "delay 400ns" --> SetSector[Set kernel sector count]
SetSector --> SetLBA[Set kernel LBA]
SetLBA --> Command[Command to read]
CheckDRQ{"(DRQ == 0)?"}
Command -- "delay 400ns" --> CheckDRQ
CheckDRQ -- Yes --> ReadStat[Read status] --> CheckDRQ
CheckDRQ -- No --> ReadData[Read data for 1 sector]
CheckDataCnt{"(data_count == 0)?"}
CheckSectCnt{"(sector_count == 0)?"}
ReadData -- "sector_count--" --> CheckDataCnt
CheckDataCnt -- Yes --> CheckSectCnt
CheckDataCnt -- No --> DataLoad[Data load 2-byte] -- "data_count--, &kernel_memory+=2" --> CheckDataCnt
CheckSectCnt -- Yes --> End([End])
CheckSectCnt -- No --> ReadStat
```

#### Implementation
- Drive master and LBA mode
- PIO mode
- Polling

| Description | Link |
| --- | --- |
| Why delay 400ns | [docs: ata delay 400ns](/docs/drv/ata/README.md#note-delay-400ns) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Header for bootloader | [docs: boot header](/docs/boot/boot_inc.md) |
| Main doucment for boot | [docs: boot](/docs/boot/README.md) |
| Main document for ATA | [docs: ata](/docs/drv/ata.md) |
| Main document for kernel | [docs: kernel](/docs/kern/README.md) |
| Main document for Fayos | [docs: fayos](/docs/README.md) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
