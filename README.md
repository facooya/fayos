# Fayos
Fayos is a 16-bit real-mode OS written in GNU Assembler.

## Build Instructions
- `make` : Creates `fayos.img` inside the `build/` directory. The `build/` directory is created automatically.

- `make clean` : Removes intermediate files generated during the make process. These files are already included in `fayos.img`, so it is safe to delete them.

- `make clean_all` : Deletes the `build/` directory and everything inside it. Note that the `fayos.img` file inside `build/` will also be removed, so be careful. If needed, make sure to copy it or move it elsewhere beforehand. This is used for a full clean reset before rebuilding.

## Quick test for Linux x86-64 using qemu
- `./tools/qemu.sh`

## Documentation
Every files follow the documentation rules, Examples:
- `boot/boot.s` - `docs/boot/boot.md`
- `kernel/args/args.s` - `docs/kernel/args/args.md`

---

## Directory Structure
- boot/ - Boot
- cmd/ - Commands
- docs/ - Documentation
- fayfs/ - File system for Fayos
- include/ - Constants only
- kernel/ - Kernel for Fayos
- lib/ - Library
- tools/ - Misc

---

> Fayos is "FAcooYa Operating System"
