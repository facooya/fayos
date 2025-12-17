# Include Readme
## Overview
Header files.
Omission `inc/`, Use like `.include "drv/vga.s"`, `.include "boot.s"` in source file. Because already seek include files in `inc/` by `as -Iinc` compiler option in Makefile.

---

## Table of Contents
- [Directory Structure](#directory-structure)
- [File List](#file-list)

---

## Directory Structure
| Name | Description | Link |
| --- | --- | --- |
| `drv` | Driver | [docs: inc drv](/docs/inc/drv/README.md) |
| `fs` | File system | [docs: inc fs](/docs/inc/fs/README.md) |

---

## File List
| Name | Description | Link |
| --- | --- | --- |
| `boot.s` | Boot header | [docs: inc boot](/docs/inc/boot.md) |
| `chr.s` | Character header | [docs: inc chr](/docs/inc/chr.md) |
| `int.s` | Interrupt header | [docs: inc int](/docs/inc/int.md) |

---

> Authors 2025 Facooya and Fanone Facooya
