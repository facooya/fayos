FAYOS - FAcooYa Operating System

FAYOS targets 16-bit x86 (real mode), uses BIOS interrupts, and is written in GNU Assembler.

# Quick test for Linux x86-64 using qemu

`make`  
`./qemu.sh`  

# Directory Note  
boot/  
build/ - *.o, *.bin, *.img  
cmd/  
drivers/ - keyboard, disk  
fs/ - fayfs, block  
kernel/ - kernel start (main loop)  
lib/ - common  
