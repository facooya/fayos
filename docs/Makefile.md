# Readme for Makefile
## Overview
Build for `fayos.img`.

---

## Table of Contents
- [Commands](#commands)
- [Process Flow](#process-flow)
- [Terms](#terms)
- [Notes](#notes)
- [Reference Links](#reference-links)

---

## Commands 
| Command | Description |
| --- | --- |
| `make`, `make all` | Build for Fayos image file, Auto generate files and directories in build directory for build. |
| `make clean` | Remove all for auto generate files and directories by build except Fayos image file in build directory. |
| `make clean_all` | Remove all for auto generate files and directories by build include build directory. |

---

## Syntax Reference
| Syntax | Description |
| --- | --- |
| `$`, `$()` | Variable. Only 1 letter possible using `$`. |
| `%` | Pattern wildcard |
| `$@` | Variable type, Equal to `$(@)`. Example: `A: B`, Indicate A |
| `$^` | Variable type, Equal to `$(^)`. Example: `A: B`, Indicate B |

| Description | Link |
| --- | --- |
| External link: standard document for make | [GNU: make](https://www.gnu.org/savannah-checkouts/gnu/make/manual/make.html) |

---

## Process Flow
1. Source file list.
1. Object file list.
    - patten substitution

### All
1. Compile source files to object files
    - objcect files in build directory
1. Make disk image for `fayos.img`
1. Add boot binrary in `fayos.img`
1. Add kernel binrary in `fayos.img`

### Clean
1. Delete binary and object files
    - delete lock and bochslog file if using bochs
1. Delete empty directories

### Clean all
1. Clean first
1. Delete image
1. Delete empty directories

---

## Terms
**Word**
| Name | Description |
| --- | --- |
| SRCS | Sources |
| OBJS | Objects |
| KERN | Kernel |
| FS | File system |
| SH | Shell |
| DRV | Driver |
| INT | Interrupt |
| LIB | Library |
| BS | Byte Size |
| NOTRUNC | No Turncate |
| BIN | Binrary |

---

## Notes
### Note Boot Area
Don't reposition `boot/boot.s` in `SRCS_GROUP_BOOT`. This file always first location in `SRCS_GROUP_BOOT`, Boot start address is `0x0000:0x7C00` in Fayos.

### Note Kernel Area
Don't reposition `kernel/kernel.s` in `SRCS_KERN`. This file always first location in `SRCS_KERN`, Kernel start address is `0x0000:0x1000` in Fayos.
And keep first `SRCS_KERN` in `SRCS_GROUP_KERN`.

---

## Reference Links
| Description | Link |
| --- | --- |
| Main document for entire | [docs: readme](/docs/README.md) |
| External link: standard document for make | [GNU: make](https://www.gnu.org/savannah-checkouts/gnu/make/manual/make.html) |

---

> Authors 2025 Facooya and Fanone Facooya
