# Fayos
Fayos is 16-bit real-mode OS.
Write by GNU Assembler.
Using BIOS interrupt.

## Quick Start
Step summary
1. Dependency install
2. Build the **Fayos**
3. Execute **Fayos**

### 1. Dependency install
Using `apt` package manager in this guide.
```bash
sudo apt update
sudo apt upgrade
sudo apt install git make binutils
```
- `git` - for the `git clone`
- `make` - build for `fayos.img`
- `binutils` - include the `as`, `ld` commands
- - `as` - GNU assembler compiler
- - `ld` - linker

### 2. Build the Fayos
```bash
git clone https://github.com/facooya/fayos.git
cd fayos
make
```
- `make` - build `fayos.img` in `build/` directory. And `build/` directory auto created.
- `make clean` - remove object and binary files in `build/` directory. Only rest the `fayos.img` in `build/` directory.
- `make clean_all` - remove `build/` directory.

### 3. Execute Fayos
Using `qemu` emulator in this guide.
Emulator install:
```bash
sudo apt qemu-system
```

Quick execute Fayos with qemu:
```bash
./tools/qemu.sh
```
The `./tools/qemu.sh` for x86-64 or amd64 architecture.

Manual execute Fayos with qemu:
```bash
qemu-system-x86_64 -drive format=raw,file=./build/fayos.img
```
- `qemu-system-[architecture] -drive format=raw,file=[path].img`

Follow the command list.

---

## Quick Start for Windows
Install linux terminal in windows:
- open windows terminal
- install the windows system in linux: `wsl --install -d Debian`
- - debian linux using `apt`
- windows reboot: `shutdown /r /t 0`
- open windows terminal
- execute linux terminal `wsl -d Debian` or `debian`
- make user and password and reboot WSL.

And follow the Quick Start.

---


## Command List
- Directory
- - `mkdir` - create new directory
- - `rmdir` - remove directory
- - `cd` - change directory
- - `ls` - show directory list

- File
- - `touch` - create new file
- - `rm` - remove file
- - `cat` - show file content

- System
- - `echo` - output string
- - `help` - show command list
- - `clear` - clear screen

---

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
