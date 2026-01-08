# Readme for Makefile
## Overview
Build for Fayos.

---

## Table of Contents
- [Commands](#commands)
- [Module Map](#module-map)
- [Make Reference](#make-reference)
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

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| Link editor script for boot | `/boot/boot.lds` | [docs: boot linker](/docs/boot/README.md#note-linker-script) |
| Link editor script for kernel | `/kern/kern.lds` | [docs: kernel linker](/docs/kern/README.md#note-linker-script) |
| Execute Fayos in Quick Emulator | `/tools/qemu.sh` | [docs: qemu](/docs/tools/qeum.md) |
| Execute Fayos in Bochs | `/tools/bochs.sh` | [docs: bochs](/docs/tools/bochs.md) |

---

## Make Reference
### Header
| Name | Description |
| --- | --- |
| `FAYOS_IMG` | Path for Fayos image |
| `BOOT_BIN` | Boot binrary |
| `KERN_BIN` | Kernel binrary |
| `TOT_SECT_CNT` | Total sector count. Minimum: 256, Maximum: 524280. |
| `SRCS_KERN` | Source file for kernel |
| `SRCS_FS` | Source file for file system |
| `SRCS_SH` | Source file for shell |
| `SRCS_DRV` | Source file for driver |
| `SRCS_INT` | Source file for interrupt |
| `SRCS_LIB` | Source file for library |
| `SRCS_GROUP_BOOT` | All source files for boot |
| `SRCS_GROUP_KERN` | All source files for kernel |
| `OBJS_BOOT` | All object files for boot |
| `OBJS_KERN` | All object files for kernel |

### Syntax
| Syntax | Description |
| --- | --- |
| `$`, `$()` | Variable. Only 1 letter possible using `$`. |
| `%` | Pattern wildcard, Useful for substitution. |
| `$@`, `$(@)` | Indicate destination. Recommand using `$@`. |
| `$^`, `$(^)` | Indicate source. Recommand using `$^`. |

| Description | Link |
| --- | --- |
| More about total sector count | [docs: note total sector count](#note-total-sector-count) |
| More about pattern wildcard | [docs: note substitution](#note-substitution) | 
| More about indicate | [docs: note indicate](#note-indicate) |

### Shell
**Command**
| Name | Usage | Description |
| --- | --- | --- |
| `as` | `as [OPTION] [FILE]` | Compiler for assembly |
| `ld` | `ld [OPTION] [FILE]` | Link editor |
| `dd` | `dd [OPTION]` | Data definition |
| `find` | `find [PATH] [EXPRESSION] [ACTION]` | Find files or directories |
| `mkdir` | `mkdir [OPTION] [DIR]` | Make directory |

**as**
| Option | Usage | Description |
| --- | --- | --- |
| `32` | `--32` | Enable 32 bit |
| `I` | `-I[DIR]` | Include default path |
| `o` | `-o [FILE]` | Object file output name |

**ld**
| Option | Usage | Description |
| --- | --- | --- |
| `T` | `-T [FILE]` | Read linker script |
| `o` | `-o [FILE]` | Output file name |

**dd**
| Option | Usage | Description |
| --- | --- | --- |
| `if` | `if=[FILE]` | Input file |
| `of` | `of=[FILE]` | Output file |
| `bs` | `bs=[BYTES]` | Block size |
| `count` | `count=[NUM]` | Block count |
| `seek` | `seek=[NUM]` | Seek. Skip block. |
| `conv` | `conv=[TYPE]` | Conversion, Type: notrunc = no truncate |

**find**
| Option | Usage | Description |
| --- | --- | --- |
| `name` | `-name [TARGET]` | Name, Expression argument. |
| `type` | `-type [TYPE]` | Type, Expression argument. Type: d = directory |
| `empty` | `-empty` | Empty, Expression argument. |
| `delete` | `-delete` | Delete, Action argument. |

**mkdir**
| Option | Usage | Description |
| --- | --- | --- |
| `p` | `-p` | Parent. Add parent directory if need. If exist no error. |

| Description | Link |
| --- | --- |
| Why 32 bit option to assembly compiler | [docs: note 32 bit](#note-option-32-bit) |

---

## Process Flow
1. Definition source files
1. Definition object files to substitute source files

**Command: all**
1. Compile and create binrary files
1. Create and initialzation Fayos image
1. Add boot binrary in Fayos image
1. Add kernel binrary in Fayos image

**Command: clean**
1. Delete binary and object files
    - delete lock and bochslog file if using bochs
1. Delete empty directories

**Command: clean all**
1. Execute clean command first
1. Delete image
1. Delete empty directories

---

## Terms
**Abbreviation**
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
| BIN | Binrary |
| TOT | Total |
| SECT | Sector |
| CNT | Count |

---

## Notes
### Note Boot Area
Don't reposition `boot/boot.s` in `SRC_BOOT`. This file always first location in `SRC_BOOT`, Boot start address is `0x0000:0x7C00` in Fayos.

### Note Kernel Area
Don't reposition `kern/kernel.s` in `SRCS_KERN`. This file always first location in `SRCS_KERN`, Kernel start address is `0x0000:0x1000` in Fayos.
And keep first `SRCS_KERN` in `SRCS_GROUP_KERN`.

### Note Total Sector Count
Formula for minimum value: `FST_RESV + KERN_TOT_SEC + sec_resv + mandatory_files + ALPHA = minimum_value` = `16 + 48 + 24 + 16 + ALPHA = 256`.
First reservation area: (16)
    - boot sector count (1)
    - superblock sector count (1)
    - align sector count for kernel (14)

Second reservation area: (24)
    - block bitmap (8)
    - inum bitmap (8)
    - inode table (8)

Mandatory files: (16)
    - root directory (8)
    - history file (8)
    - log files

Alpha: Example like spare for file system

Formula for maximum value: `MAXIMUM_BLOCK_COUNT * SECTOR_COUNT_PER_BLOCK = maximum_value` = `0xFFFF * 0x08 = 0x7FFF8 = 524280`.
If over maximum value, It will be fine. But Fayos working only in maximum value.

### Note Substitution
- Input : Pattern = Replace
- Example: `OBJS_KERN = $(kern/kern.s:%.s=./build/%.o)`
    - `$(kern/kern.s : %.s = ./build/%.o)`
    - `% = kern/kern`
    - `$(kern/kern.s = ./build/kern/kern.o)`
    - `OBJS_KERN = ./build/kern/kern.o`

### Note Indicate
- Destination: Source
- Example: `./build/kern/kern.o: kern/kern.s`
    - `as $^ -o $@`
    - `$^ = kern/kern.s`
    - `$@ = ./build/kern/kern.o`
    - `as kern/kern.s -o ./build/kern/kern.o`

### Note Option 32 Bit
- Q. Why enable 32 bit option in assembly compiler?
- A. Select 32 bit architecture is support 16 bit. And no have option to enable 16 bit.
- Q. How enable 16 bit?
- A. Enable 32 bit and `.code16` in source files header.

---

## Reference Links
| Description | Link |
| --- | --- |
| Document for Fayos | [docs: readme](/docs/README.md) |
| External link: standard document for make | [GNU: make](https://www.gnu.org/savannah-checkouts/gnu/make/manual/make.html) |

---

> Authors 2025-2026 Facooya and Fanone Facooya
