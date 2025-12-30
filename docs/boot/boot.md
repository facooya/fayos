# Boot
## Overview
Bootloader main for Fayos.
Display contol with direct VGA access memory.
Kernel sectors read with ATA PIO mode polling method.
Write the boot signature via linker script.

---

## Table of Contents
- [API Reference](#api-reference)
- - [`_start`](#_start)
- - [`_vga_clr`](#_vga_clr)
- - [`_vga_puts`](#_vga_puts)
- - [`_ata_read`](#_ata_read)
- [Reference Links](#reference-links)

---

## API Reference
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
Init([ Initialization ])
Init --> Stack[ Set stack pointer ]
Stack --> VGA_Clear[[ _vga_clr ]]
VGA_Clear --> VGA_Puts[[ _vga_puts ]]
VGA_Puts --> KernelMemory[ Set memory for kernel ]
KernelMemory --> ATA_Read[[ _ata_read ]]
ATA_Read --> JumpKernel([ Jump to kernel memory ])
```

#### Implementation
- Initialization
    - Clear interrupt and clear direction
    - init registers: `ax, ds, es, ss, sp, bp`
    - mandatory to zero: `ds, ss`
- Set stack pointer
    - `sp = 0x7C00`
- Clear screen
- Print boot message
- Read kernel sectors
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
Init([ Set VGA memroy ])
Init --> GetRowCol[ Get screen row count and column count ]
GetRowCol --> CalcSize[ Calculate screen size ]
CalcSize --> ClearCheck{ "(screen_size == 0)?" }
ClearCheck --> Yes --> End([ Set cursor to zero ])
ClearCheck --> No --> Loop[ "screen_size--" ]
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
1. Set VGA memory
1. Get cursor
1. Set VGA memory to current cursor
1. Put string to VGA memory with color attribute
    - supports newline
1. Set cursor to last position

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
1. Set drive mode
    - set drive master and LBA mode
    - delay 400ns
1. Set sector count and LBA and send command to read
    - after send command delay 400ns
1. Data request check every sectors
1. Data read
    - if sector count 0, done

| Description | Link |
| --- | --- |
| Why delay 400ns | [docs: ata delay 400ns](/docs/drv/ata/README.md#note-delay-400ns) |

---

## Reference Links
| Description | Link |
| --- | --- |
| Header for bootloader | [docs: boot header](/docs/inc/boot.md) |
| Main doucment for boot | [docs: boot](/docs/boot/README.md) |
| Main document for ATA | [docs: ata](/docs/drv/ata.md) |
| Main document for kernel | [docs: kernel](/docs/kern/README.md) |
| Main document for Fayos | [docs: fayos](/docs/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
