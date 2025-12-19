# Keyboard Readme
## Overview
Keyboard driver. Invoke keyboard driver scan code full in kernel main loop, Scan code full by PS2 interrupt.

---

## Table of Contents
- [Module Map](#module-map)
- [Terms](#terms)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| Keyboard header | `/inc/drv/kbd.s` | [docs: kbd header](/docs/inc/drv/kbd.md) |
| Keyboard data definition | `/drv/kbd/kbd_data.s` | [docs: kbd data](/docs/drv/kbd/kbd_data.md) |
| Keyboard run. Call by kernel loop | `/drv/kbd/kbd_run.s` | [docs: kbd run](/docs/drv/kbd/kbd_run.md) |
| Keyboard process. Call by keyboard run | `/drv/kbd/kbd_proc.s` | [docs: kbd proc](/docs/drv/kbd/kbd_proc.md) |
| Keyboard update modifer flag | `/drv/kbd/kbd_upd_mflg.s` | [docs: kbd upd mflg](/docs/drv/kbd/kbd_upd_mflg.md) |
| Keyboard convert keycode. Convert scancode to keycode. | `/drv/kbd/kbd_conv_kc.s` | [docs: kbd conv kc](/docs/drv/kbd/kbd_conv_kc.md) |
| Keyboard handler for backspace key | `/drv/kbd/kbd_hdl_bs.s` | [docs: kbd hdl bs](/docs/drv/kbd/kbd_hdl_bs.md) |
| Keyboard handler for carriage return key | `/drv/kbd/kbd_hdl_cr.s` | [docs: kbd hdl cr](/docs/drv/kbd/kbd_hdl_cr.md) |
| Keyboard handler for arrow up key | `/drv/kbd/kbd_hdl_up.s` | [docs: kbd hdl up](/docs/drv/kbd/kbd_hdl_up.md) |
| Keyboard handler for arrow down key | `/drv/kbd/kbd_hdl_down.s` | [docs: kbd hdl down](/docs/drv/kbd/kbd_hdl_down.md) |
| Keyboard handler for arrow left key | `/drv/kbd/kbd_hdl_left.s` | [docs: kbd hdl left](/docs/drv/kbd/kbd_hdl_left.md) |
| Keyboard handler for arrow right key | `/drv/kbd/kbd_hdl_right.s` | [docs: kbd hdl right](/docs/drv/kbd/kbd_hdl_right.md) |

---

## Terms
| Name | Description |
| --- | --- |
| PS2 | Personal System 2 |
| KBD | Keyboard |
| SC | Scan Code |
| KC | Key Code |
| MFLG | Modifier Flag |
| CONV | Convert |
| PROC | Process |

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for PS2 | [docs: ps2](/docs/drv/ps2/README.md) |
| Main document for driver | [docs: driver](/docs/drv/README.md) |
| Standard document for keyboard (External Link) | [OSDev: keyboard](https://wiki.osdev.org/PS/2_Keyboard) |

---

> Authors 2025 Facooya and Fanone Facooya
