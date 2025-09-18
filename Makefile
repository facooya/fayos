# Don't reposition "kernel/kernel.s",
# This file always first location in Fayos.
# Kernel address - segment:offset = 0x0000:0x1000

SRCS = \
kernel/kernel.s \
\
int/pic_init.s \
int/ivt_init.s \
int/interrupt.s \
int/irq_kbd.s \
\
drv/vga/vga_putc.s \
drv/vga/vga_puts.s \
drv/vga/vga_clr.s \
drv/vga/vga_clr_line.s \
drv/vga/vga_init_curs.s \
drv/vga/vga_get_curs.s \
drv/vga/vga_set_curs.s \
\
drv/disp/write.s \
\
drv/kbd/chk_scan_code_set.s \
drv/kbd/off_conf_byte_bit6.s \
drv/kbd/read_key.s \
drv/kbd/keymap.s \
\
drv/disk/read_disk2.s \
drv/disk/read_disk3.s \
drv/disk/write_disk2.s \
\
kernel/sys/_sys_disk.s \
\
kernel/kbd/kbd_main.s \
kernel/kbd/kbd_lsh.s \
kernel/kbd/kbd_rsh.s \
\
kernel/kbd/_key_bs.s \
kernel/kbd/_key_cr.s \
kernel/kbd/_key_down.s \
kernel/kbd/_key_left.s \
kernel/kbd/_key_right.s \
kernel/kbd/_key_up.s \
kernel/kbd/_kbd_hist_line.s \
\
kernel/disk/disk.s \
kernel/disk/dap.s \
kernel/disk/dap_utils.s \
kernel/disk/set_dap_blk_lba.s \
\
kernel/mem/mem.s \
kernel/mem/alloc_mem.s \
kernel/mem/free_mem.s \
\
kernel/io/buf.s \
kernel/io/cursor.s \
\
kernel/lib/bufcpy.s \
kernel/lib/bufzero.s \
\
kernel/dbg/dbg_args.s \
kernel/dbg/dbg_paths.s \
kernel/dbg/dbg_cursor.s \
kernel/dbg/dbg_buf.s \
kernel/dbg/dbg_trace.s \
kernel/dbg/dbg_utils.s \
\
kernel/dbg/num/dbg_num.s \
kernel/dbg/num/dbg_reg.s \
\
\
fs/cache.s \
\
fs/super/super.s \
fs/super/_super_alloc_lba.s \
fs/super/_super_make_root.s \
fs/super/_super_set_bitmap.s \
fs/super/_super_set_lba.s \
fs/super/_super_write_data.s \
\
fs/inode/add_inode.s \
fs/inode/clear_inode.s \
fs/inode/read_inode.s \
fs/inode/update_inode.s \
\
fs/dentry/add_dentry.s \
fs/dentry/lookup_dentry.s \
\
fs/bit/alloc_bit.s \
fs/bit/clear_bit.s \
fs/bit/set_bit.s \
\
fs/path/path.s \
fs/path/read_paths.s \
fs/path/tok_paths.s \
fs/path/build_paths.s \
\
\
shell/history.s \
\
shell/args/args.s \
shell/args/tok_args.s \
shell/args/build_args.s \
shell/args/parse_args.s \
\
shell/exec/exec_cmd.s \
shell/exec/exec_redir.s \
\
shell/prompt/add_ps1_path.s \
shell/prompt/sub_ps1_path.s \
shell/prompt/build_ps1_path.s \
shell/prompt/build_ps1.s \
shell/prompt/init_ps1.s \
shell/prompt/prompt.s \
\
shell/cmd/cmd_map.s \
\
shell/cmd/sys/test.s \
shell/cmd/sys/echo.s \
shell/cmd/sys/help.s \
shell/cmd/sys/clear.s \
\
shell/cmd/file/cat.s \
shell/cmd/file/rm.s \
shell/cmd/file/touch.s \
\
shell/cmd/dir/cd.s \
shell/cmd/dir/ls.s \
shell/cmd/dir/mkdir.s \
shell/cmd/dir/rmdir.s \
\
\
lib/re.s \
\
lib/dir/get_bottom_dir.s \
lib/dir/rm_dir.s \
\
lib/file/fparse_lines.s \
\
lib/err/emsg_common.s \
lib/err/emsg_io.s \
lib/err/emsg_syn.s \
\
lib/put/putf.s \
lib/put/puts.s \
lib/put/putns.s \
lib/put/put_utils.s \
\
lib/str/memcmp.s \
lib/str/memcpy.s \
lib/str/memset.s \
lib/str/strlen.s

OBJS = $(SRCS:%.s=./build/%.o)

# ALL
all: ./build/fayos.img

./build/fayos.img: ./build/boot.bin ./build/kernel.bin | ./build/
	dd if=/dev/zero of=./build/fayos.img bs=512 count=20480
	dd if=./build/boot.bin of=./build/fayos.img bs=512 count=1 conv=notrunc
	dd if=./build/kernel.bin of=./build/fayos.img bs=512 seek=16 conv=notrunc

./build/boot.bin: ./boot/boot.s | ./build/
	as --32 -Iboot ./boot/boot.s -o ./build/boot.o
	ld --oformat binary -m elf_i386 -Ttext 0x7C00 ./build/boot.o -o ./build/boot.bin

./build/kernel.bin: $(OBJS) | ./build/
	ld -m elf_i386 -T ./tools/linker.ld $(OBJS) -o ./build/kernel.bin

./build/%.o: %.s | ./build/
	mkdir -p $(dir $@)
	as --32 -Iinclude $< -o $@

./build/:
	mkdir -p $@

# CLEAN
clean:
	find ./build/ -name "*.bin" -delete
	find ./build/ -name "*.o" -delete
	find ./build/ -name "bochslog" -delete
	find ./build/ -type d -empty -delete

clean_all: clean
	find ./build/ -name "*.img" -delete
	find ./build/ -type d -empty -delete
