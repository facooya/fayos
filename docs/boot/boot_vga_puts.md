# Boot VGA Put String
## Overview
VGA (Video Graphic Array) put string logic in Bootloader. Direct print default color background black, foreground white. Put sting to VGA memory.

---

## API Reference
### Parameters
1. `ub8 *str`

### Requires
- `N/A`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Set VGA memory
1. Get cursor
1. Set VGA memory to current cursor
1. Put string to VGA memory with color attribute
    - supports newline
1. Set cursor to last position

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for boot | [docs: boot](/docs/boot/README.md) |
| VGA puts for kernel | [docs: vga puts](/docs/drv/vga/vga_puts.md) |

---

> Authors 2025 Facooya and Fanone Facooya
