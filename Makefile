OBJS = ./build/kernel.o ./build/cli.o ./build/print.o \
  ./build/err.o ./build/kbd.o ./build/disk.o

all: ./build/boot.img

./build/boot.img: ./build/boot.bin ./build/kernel.bin
	dd if=/dev/zero of=./build/boot.img bs=512 count=2880
	dd if=./build/boot.bin of=./build/boot.img bs=512 count=1 conv=notrunc
	dd if=./build/kernel.bin of=./build/boot.img bs=512 seek=32 conv=notrunc

./build/boot.bin: ./boot/boot.s
	as --32 ./boot/boot.s -o ./build/boot.o
	ld --oformat binary -m elf_i386 -Ttext 0x7C00 ./build/boot.o -o ./build/boot.bin

./build/kernel.bin: $(OBJS)
	ld -m elf_i386 -T ./build/linker.ld $(OBJS) -o ./build/kernel.bin

./build/kernel.o: ./kernel/kernel.s
	as --32 ./kernel/kernel.s -o ./build/kernel.o

./build/cli.o: ./kernel/cli.s
	as --32 ./kernel/cli.s -o ./build/cli.o

./build/print.o: ./lib/print.s
	as --32 ./lib/print.s -o ./build/print.o

./build/err.o: ./lib/err.s
	as --32 ./lib/err.s -o ./build/err.o

./build/kbd.o: ./drivers/kbd.s
	as --32 ./drivers/kbd.s -o ./build/kbd.o

./build/disk.o: ./drivers/disk.s
	as --32 ./drivers/disk.s -o ./build/disk.o

clean:
	rm -f ./build/*.o ./build/*.bin ./build/*.img
	