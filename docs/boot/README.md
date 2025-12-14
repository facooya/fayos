# Readme for Boot
## Overview
Bootloader for Fayos.
Display contol with direct VGA access memory.
Kernel sectors read with ATA PIO mode polling method.
Write the boot signature via linker script.
After kernel jump, Boot done.

---

## Table of Contents
- [Module Map](#module-map)
- [Terms](#terms)
- [Notes](#notes)
- [Reference Links](#reference-links)

---

## Module Map
| Description | Source Path | Docs Link |
| --- | --- | --- |
| Start of boot | `/boot/boot.s` | [docs: boot](/docs/boot/boot.md) |
| ATA read in boot | `/boot/boot_ata_read_sect.s` | [docs: boot ata read](/docs/boot/boot_ata_read_sect.md) |
| VGA clear display in boot | `/boot/boot_vga_clr.s` | [docs: boot vga clear](/docs/boot/boot_vga_clr.md) |
| VGA put sting in boot | `/boot/boot_vga_puts.s` | [docs: boot vga puts](/docs/boot/boot_vga_puts.md) |
| Header for bootloader | `/inc/boot.s` | [docs: boot header](/docs/inc/boot.md) |
| Linker script for boot | `/boot/boot.lds` | [docs: linker for boot](#note-linker-script) |

---

## Terms
| Name | Description |
| --- | --- |
| ATA | Advanced Technology Attachement |
| VGA | Video Graphic Array |
| LDS | Link Editor Script |
| RODATA | Read Only Data |
| BSS | Block Started by Symbol |
| CLD | Clear Direction |
| CLI | Clear Interrupt |

---

## Notes
### Note Linker Script
Output format is binary and architecture is i386.
Set entry name `_start`.
Set start section is `0x7C00`. Sections layout `text, rodata, data, bss`. And set position `0x7DFE` for last 2-byte in bootloader, Insert boot signiture `0xAA55`.

### Note Clear Direction
- Q. Why use?
- A. More safely and explicitly. Using command `cld` in boot. Direction flag effect for related string command.

### Note Clear Interrupt
Disable interrupt in bootloader. And enable interrupt when initialization logic end.

---

## Reference Links
| Description | Link |
| --- | --- |
| Main doucment for kernel | [docs: kernel](/docs/kern/kern.md) |

---

> Authors 2025 Facooya and Fanone Facooya
