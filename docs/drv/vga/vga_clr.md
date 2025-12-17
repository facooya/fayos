# VGA Clear
## Overview
Clear for entire screen.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `vga_size`
- `vga_set_curs()`

### Modifies
- `N/A`

### Returns
- `N/A`

---

## Process Flow
1. Clear screen to write space.
    - color attribute background=black, foreground=white
1. Set cursor position to zero

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |
| VGA set cursor | [docs: vga set cursor](/docs/drv/vga/vga_set_curs.md) |

---

> Authors 2025 Facooya and Fanone Facooya
