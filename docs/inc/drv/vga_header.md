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
| `VGA_PORT_CRTC_CMD` | Command port for CRTC. |
| `VGA_PORT_CRTC_DATA` | Data port for CRTC. Read/Write 1-byte |
| `VGA_CMD_COL` | Return columns count |
| `VGA_CMD_CHR_H` | Character height in bits 0-4 |
| `VGA_CMD_ROW_HI` | Dispaly height high value in bit 1 and bit 6 |
| `VGA_CMD_ROW_LO` | Display height low value in bits 0-7 |
| `VGA_CMD_CURS_START` | Command for cursor start |
| `VGA_CMD_CURS_END` | Command for cursor end |
| `VGA_CMD_CURS_POS_HI` | Command for cursor position high area |
| `VGA_CMD_CURS_POS_LO` | Command for cursor position low area |
| `VGA_MASK_CHR_H` | Mask for character height |
| `VGA_ROW_HI_8` | Display height high value point to bit 8 |
| `VGA_ROW_HI_9` | Display height high value point to bit 9 |
| `VGA_CURS_DISABLE` | Cursor disable bit in cursor start register |
| `VGA_CURS_START_LINE` | Cursor draw start line position |
| `VGA_CURS_END_LINE` | Cursor draw end line position |
| `VGA_CURS_BLOCK_START_LINE` | Block cursor start line position |

---

## Terms
| Name | Description |
| --- | --- |
| VGA | Video Graphic Array |
| CURS | Cursor |
| CRTC | Cathode Ray Tube Contoller |

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for VGA | [docs: vga](/docs/drv/vga.md) |
| Directory document for include | [docs: dir include](/docs/inc/README.md) |

---

> Maintained by Facooya and Fanone Facooya, 2025-2026
