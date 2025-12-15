# Boot VGA Clear
## Overview
VGA (Video Graphic Array) clear in bootloader. Clear screen to default color background black, foreground white.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `N/A`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Set VGA memory
1. Get display size
1. Clear to using character space and defalut color
    - default color attribute: bg=black, fg=white
1. Set cursor to initial position

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for boot | [docs: boot](/docs/boot/README.md) |
| VGA clear for kernel | [docs: vga clear](/docs/drv/vga/vga_clr.md) |

---

> Authors 2025 Facooya and Fanone Facooya
