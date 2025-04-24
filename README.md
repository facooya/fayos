# FAYOS - FAcooYa Operating System
FAYOS targets 16-bit x86 (real mode), uses BIOS interrupts, and is written in GNU Assembler.   

## Build Instructions
- `make` : Creates `fayos.img` inside the `build/` directory. The `build/` directory is created automatically.

- `make clean` : Removes intermediate files generated during the make process. These files are already included in `fayos.img`, so it is safe to delete them.

- `make clean_all` : Deletes the `build/` directory and everything inside it. Note that the `fayos.img` file inside `build/` will also be removed, so be careful. If needed, make sure to copy it or move it elsewhere beforehand. This is used for a full clean reset before rebuilding.

# Quick test for Linux x86-64 using qemu
- `./tools/qemu.sh`

## Directory note
boot/ - boot  
cmd/ - commands  
docs/ - documentation  
fs/fayfs/ - file system  
include/ - constants only  
kernel/ - main  
lib/ - library  
sys/ - BIOS interrupt interface  
templates/ - copy and paste  
tools/ - misc  
