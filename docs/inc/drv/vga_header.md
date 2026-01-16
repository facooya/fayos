# VGA Header
## Overview
Header for VGA.

---

## Table of Contents
- [Constants](#constants)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Constants
| Name | Description |
| --- | --- |
| `VGA_ATTR_COLOR` | Attribute default color. `4-bit:4-bit = background:foreground`. Default color is `0:7 = black:light_gray` |
| `VGA_SCROLL_CNT` | Screen scroll max count |
| `VGA_MEM` | VGA Memory, segment:offset |
| `VGA_PORT_CURS_CMD` | Port for cursor command |
| `VGA_PORT_CURS_DATA` | Port for cursor data. Read/Write 1-byte |
| `VGA_ADDR_ROW` | Address for row. Total row index. Read only 1-byte. |
| `VGA_ADDR_COL` | Addres for column. Total column size. Read only 2-byte. |
| `VGA_CMD_CURS_START` | Command for cursor start |
| `VGA_CMD_CURS_END` | Command for cursor end |
| `VGA_CMD_CURS_POS_HI` | Command for cursor position high area |
| `VGA_CMD_CURS_POS_LO` | Command for cursor position low area |
| `VGA_CURS_DISABLE` | Cursor disable bit in cursor start register |
| `VGA_CURS_START_LINE` | Cursor draw start line position |
| `VGA_CURS_END_LINE` | Cursor draw end line position |

---

## Terms
| Name | Description |
| --- | --- |
| VGA | Video Graphic Array |
| CURS | Cursor |

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for VGA | [docs: vga](/docs/drv/vga.md) |
| Directory document for include | [docs: dir include](/docs/inc/README.md) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
