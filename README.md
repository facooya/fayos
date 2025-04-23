# FAYOS - FAcooYa Operating System
FAYOS targets 16-bit x86 (real mode), uses BIOS interrupts, and is written in GNU Assembler.

# Quick test for Linux x86-64 using qemu
## Build
- `make`
- `./qemu.sh`

## Clean
- `make clean`

# Directory note
boot/ - boot  
build/ - linker.ld, make (*.o, *.bin, *.img)  
cmd/ - commands  
docs/ - documentation  
fs/fayfs/ - file system  
include/ - constants only (.equ)  
kernel/ - main  
lib/ - library  
sys/ - hardware interrupt interface  
templates/ - copy and paste  
