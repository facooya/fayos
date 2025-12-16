# Readme for VGA
## Overview
Readme for VGA (Video Graphic Array). Base for display driver.

---

## Table of Contents
- [Module Map](#module-map)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| Header for VGA | `/inc/drv/vga.s` | [docs: vga header](/docs/inc/drv/vga.md) |
| Data definition | `/drv/vga/vga_data.s` | [docs: vga data](/docs/drv/vga/vga_data.md) |
| Initialization | `/drv/vga/vga_init.s` | [docs: vga init](/docs/drv/vga/vga_init.md) |
| Clear screen | `/drv/vga/vga_clr.s` | [docs: vga clear](/docs/drv/vga/vga_clr.md) |
| One line clear in screen | `/drv/vga/vga_clr_line.s` | [docs: vga clear line](/docs/drv/vga/vga_clr_line.md) |
| Initialization for cursor | `/drv/vga/vga_init_curs.s` | [docs: vga init cursor](/docs/drv/vga/vga_init_curs.md) |
| Get cursor position | `/drv/vga/vga_get_curs.s` | [docs: vga get cursor](/docs/drv/vga/vga_get_curs.md) |
| Set cursor position | `/drv/vga/vga_set_curs.s` | [docs: vga set curs](/docs/drv/vga/vga_set_curs.md) |
| Put character to screen | `/drv/vga/vga_putc.s` | [docs: vga putc](/docs/drv/vga/vga_putc.md) |
| Put string to screen | `/drv/vga/vga_puts.s` | [docs: vga puts](/docs/drv/vga/vga_puts.md) |
| Put length string to screen | `/drv/vga/vga_putls.s` | [docs: vga putls](/docs/drv/vga/vga_putls.md) |
| Shift up one line | `/drv/vga/vga_shu.s` | [docs: vga shift up](/docs/drv/vga/vga_shu.md) |

---

## Terms
| Name | Description |
| --- | --- |
| VGA | Video Graphic Array |
| DISP | Display |
| CURS | Cursor |
| SHU | Shift Up |

---

## Notes
### Note VGA Size
- ROW: `TOTAL_ROW - 1` in screen
- COLUMN: Total column in screen
    - `ROW * COLUMN = last_row_offset`
    - `last_offset + COLUMN = total_size`
- Q. Why `ROW * COLUMN` is not total size?
- A. VGA address row have index value. But VGA address column have size value.
- Q. Why using `last_row_offset + COLUMN`?
- A. More faster than `(ROW + 1) * COLUMN`. And necessary need last offset. Already last row offset calculated. Just `last_row_offset + COLUMN` is total size.
- Q. Why `ROW * COLUMN` in `vga_last_row_off`?
- A. The `ROW * COLUMN` is size. But VGA using index, So start 0. So size value point the last row start offset.

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for driver | [docs: driver](/docs/drv/README.md) |
| Main document for display | [docs: display](/docs/drv/disp/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
