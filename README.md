# Fayos
Fayos is 16-bit real-mode OS.
Write by GNU Assembler.

- [Quick Start](#quick-start)
- [Quick Start for Windows](#quick-start-for-windows)
- [Command List](#command-list)
- [Directory Structure](#directory-structure)

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
#### 3.1. [Optional] Qemu
Emulator install:
```bash
sudo apt install qemu-system
```

Quick execute:
```bash
./tools/qemu.sh
```
The `./tools/qemu.sh` for **amd64** architecture.

Manual execute:
```bash
qemu-system-x86_64 -drive format=raw,file=./build/fayos.img
```
- `qemu-system-[architecture] -drive format=raw,file=[path].img`

Follow the **Command List** section.

#### 3.2. [Optional] Bochs
Emulator install:
```bash
sudo apt install bochs bochsbios vgabios bochs-sdl
```

Quick execute:
```bash
./tools/bochs.sh
```
- Bochs log default path: `build/bochslog`

Manual execute:
Modify `tools/bochsrc` file if you need.
```bash
bochs -q -f ./tools/bochsrc
```

Follow the **Command List** section.

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

And follow the **Quick Start** section.

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

## Directory Structure
- `boot/` - Boot
- `docs/` - Documentation
- `drv/` - Driver
- `fs/` - File System: Fayfs only
- `inc/` - Include: Constants only
- `int/` - Interrupt
- `kernel/` - Kernel
- `lib/` - Library
- `shell/` - Shell
- `tools/` - Tools: Misc

More directory structure in `docs/`. Examples: `docs/kernel/README.md` and find **Directory Structure** section.

---

> Fayos is "FAcooYa Operating System"
