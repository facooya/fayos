FAYOS - FAcooYa Operating System

FAYOS targets 16-bit x86 (real mode), uses BIOS interrupts, and is written in GNU Assembler.

# Quick test for Linux x86-64 using qemu

Build  
`make`  
`./qemu.sh`  

Clean  
`make clean`  

# Directory Note  
boot/ - boot  
build/ - linker.ld, make (*.o, *.bin, *.img)  
cmd/ - commands  
docs/ - documentation  
drivers/ - keyboard, disk  
fs/fayfs/ - file system  
kernel/ - kernel start (main loop)  
lib/ - common  
