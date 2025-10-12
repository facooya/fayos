# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025 Facooya and Fanone Facooya
#
# Make file for fayos.img

# Don't reposition "boot/boot.s",
# This file always first location in Fayos.
# Boot start address - segment:offset = 0x0000:0x7C00
BOOT_SRCS = \
boot/boot.s \
boot/boot_vga_puts.s \
boot/boot_vga_clr.s \
boot/boot_ata_read_sect.s

# Don't reposition "kern/kern.s",
# This file always first location in Fayos.
# Kernel address - segment:offset = 0x0000:0x1000
SRCS_KERN = \
kern/kern.s \
\
kern/kbd/kbd_main.s \
kern/kbd/kbd_lsh.s \
kern/kbd/kbd_rsh.s \
\
kern/kbd/_key_bs.s \
kern/kbd/_key_cr.s \
kern/kbd/_key_left.s \
kern/kbd/_key_right.s \
\
kern/disk/dap.s \
kern/disk/dap_utils.s \
kern/disk/set_dap_blk_lba.s \
\
kern/mem/mem.s \
kern/mem/alloc_mem.s \
kern/mem/free_mem.s \
\
kern/io/buf.s \
kern/io/cursor.s \
\
kern/lib/bufcpy.s \
kern/lib/bufzero.s \
\
kern/dbg/dbg_args.s \
kern/dbg/dbg_paths.s \
kern/dbg/dbg_cursor.s \
kern/dbg/dbg_buf.s \
kern/dbg/dbg_trace.s \
kern/dbg/dbg_utils.s \
\
kern/dbg/num/dbg_num.s \
kern/dbg/num/dbg_reg.s

# File System
SRCS_FS = \
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
fs/path/build_paths.s

# Shell
SRCS_SH = \
sh/history.s \
\
sh/args/args.s \
sh/args/tok_args.s \
sh/args/build_args.s \
sh/args/parse_args.s \
\
sh/exec/exec_cmd.s \
sh/exec/exec_redir.s \
\
sh/prompt/add_ps1_path.s \
sh/prompt/sub_ps1_path.s \
sh/prompt/build_ps1_path.s \
sh/prompt/build_ps1.s \
sh/prompt/init_ps1.s \
sh/prompt/prompt.s \
\
sh/cmd/cmd_map.s \
\
sh/cmd/sys/test.s \
sh/cmd/sys/echo.s \
sh/cmd/sys/help.s \
sh/cmd/sys/clear.s \
\
sh/cmd/file/cat.s \
sh/cmd/file/rm.s \
sh/cmd/file/touch.s \
\
sh/cmd/dir/cd.s \
sh/cmd/dir/ls.s \
sh/cmd/dir/mkdir.s \
sh/cmd/dir/rmdir.s

# Driver
SRCS_DRV = \
drv/ata/ata_get_sect.s \
drv/ata/ata_read_sect.s \
drv/ata/ata_read_blk.s \
drv/ata/ata_write_sect.s \
drv/ata/ata_write_blk.s \
\
drv/ps2/ps2_chk_sc_set.s \
drv/ps2/ps2_init.s \
drv/ps2/ps2_xlate_off.s \
drv/ps2/ps2_read_sc.s \
\
drv/vga/vga.s \
drv/vga/vga_putc.s \
drv/vga/vga_puts.s \
drv/vga/vga_putls.s \
drv/vga/vga_clr.s \
drv/vga/vga_clr_line.s \
drv/vga/vga_init_curs.s \
drv/vga/vga_get_curs.s \
drv/vga/vga_set_curs.s \
drv/vga/vga_shu.s \
\
drv/kbd/kbd_data.s \
drv/kbd/kbd_keymap.s \
drv/kbd/kbd_upd_mflg.s \
drv/kbd/kbd_upd_hist.s \
drv/kbd/kbd_sctokc.s \
drv/kbd/kbd_key_up.s \
drv/kbd/kbd_key_down.s

# Interrupt
SRCS_INT = \
int/pic_init.s \
int/ivt_init.s \
int/interrupt.s \
int/irq_kbd.s

# Library
SRCS_LIB = \
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

SRCS = \
$(SRCS_KERN) \
$(SRCS_FS) \
$(SRCS_SH) \
$(SRCS_DRV) \
$(SRCS_INT) \
$(SRCS_LIB)

BOOT_OBJS = $(BOOT_SRCS:%.s=./build/%.o)
OBJS = $(SRCS:%.s=./build/%.o)

# ALL
all: ./build/fayos.img

./build/fayos.img: ./build/boot.bin ./build/kern.bin | ./build/
	dd if=/dev/zero of=./build/fayos.img bs=512 count=20480
	dd if=./build/boot.bin of=./build/fayos.img bs=512 count=1 conv=notrunc
	dd if=./build/kern.bin of=./build/fayos.img bs=512 seek=16 conv=notrunc

./build/boot.bin: $(BOOT_OBJS) | ./build/
	ld -T ./boot/boot.lds $(BOOT_OBJS) -o $@

./build/kern.bin: $(OBJS) | ./build/
	ld -T ./kern/kern.lds $(OBJS) -o $@

./build/%.o: %.s | ./build/
	mkdir -p $(dir $@)
	as --32 -Iinc $< -o $@

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
