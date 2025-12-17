# VGA Header
## Overview
Header for VGA (Video Graphic Array).

## Constants
| Name | Description |
| --- | --- |
| `VGA_MEM` | VGA Memory, segment:offset |
| `VGA_ATTR_COLOR` | Attribute default color. `4-bit:4-bit = background:foreground`. Default color is `0:7 = black:light_gray` |
| `VGA_PORT_CURS_CMD` | Port for cursor command |
| `VGA_PORT_CURS_DATA` | Port for cursor data. Read/Write 1-byte |
| `VGA_ADDR_ROW` | Address for row. Total row index. Read only 1-byte. |
| `VGA_ADDR_COL` | Addres for column. Total column size. Read only 2-byte. |
| `VGA_CMD_CURS_POS_HI` | Command for cursor position high area |
| `VGA_CMD_CURS_POS_LO` | Command for cursor position low area |

## Reference Links
| Description | Link |
| --- | --- |
| Main document for VGA | [docs: vga](/docs/drv/vga/README.md) |

---

> Authors 2025 Facooya and Fanone Facooya
