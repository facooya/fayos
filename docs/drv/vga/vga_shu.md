# VGA Shift Up
## Overview
VGA (Video Graphic Array) shift up. Copy "second line to last line", Paste "first line to last line - 1" position. Simliar to shift up in screen, But actually work Shift left by column size in VGA memory.

---

## API Reference
### Parameters
- `N/A`

### Requires
- `vga_last_row_off`
- `vga_set_curs()`
- `vga_clr_line()`

### Modifies
- VGA Memory

### Returns
- `N/A`

---

## Process Flow
1. Set cursor last row start offset (pre-update)
1. Overwrite current line from next line
1. Clear last line

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |
| VGA set cursor | [docs: vga set cursor](/docs/drv/vga/vga_set_curs.md) |
| VGA clear line | [docs: vga clear line](/docs/drv/vga/vga_clr_line.md) |

---

> Authors 2025 Facooya and Fanone Facooya
