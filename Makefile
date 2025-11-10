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
kern/kern_data.s \
\
kern/mem/mem_data.s \
kern/mem/mem_alloc.s \
kern/mem/mem_free.s \
\
kern/dbg/dbg_args.s \
kern/dbg/dbg_path_cv.s \
kern/dbg/dbg_curs.s \
kern/dbg/dbg_sbuf.s \
kern/dbg/dbg_trace.s \
kern/dbg/dbg_utils.s \
kern/dbg/dbg_fsp.s \
\
kern/dbg/num/dbg_num.s \
kern/dbg/num/dbg_reg.s

# File System
SRCS_FS = \
fs/fs_data.s \
fs/fs_open.s \
fs/fs_add.s \
fs/fs_rm.s \
\
fs/sb/sb_run.s \
fs/sb/sb_alloc_lba.s \
fs/sb/sb_make_root.s \
fs/sb/sb_set_bm.s \
fs/sb/sb_write_dpi.s \
\
fs/ind/ind_add.s \
fs/ind/ind_clr.s \
\
fs/de/de_add.s \
fs/de/de_add_dots.s \
fs/de/de_seek.s \
\
fs/bm/bm_alloc.s \
fs/bm/bm_clr.s \
fs/bm/bm_set.s \
\
fs/lib/fsp_init.s \
fs/lib/fsp_read.s \
fs/lib/fsp_write.s \
\
fs/lib/fs_path.s \
fs/lib/fs_tok_path.s \
fs/lib/fs_build_path.s \
fs/lib/fs_read_path.s \
\
fs/lib/fs_blk_to_lba.s

# Shell
SRCS_SH = \
sh/args/args.s \
sh/args/tok_args.s \
sh/args/build_args.s \
sh/args/parse_args.s \
\
sh/exec/exec_cmd.s \
sh/exec/exec_redir.s \
\
sh/hist/history.s \
sh/hist/hist_upd_cl.s \
\
sh/ps/add_ps1_path.s \
sh/ps/sub_ps1_path.s \
sh/ps/build_ps1_path.s \
sh/ps/build_ps1.s \
sh/ps/init_ps1.s \
sh/ps/prompt.s \
\
sh/cmd/cmd_map.s \
\
sh/cmd/sys/cmd_test.s \
sh/cmd/sys/cmd_echo.s \
sh/cmd/sys/cmd_help.s \
sh/cmd/sys/cmd_clear.s \
\
sh/cmd/file/cmd_cat.s \
sh/cmd/file/cmd_rm.s \
sh/cmd/file/cmd_touch.s \
\
sh/cmd/dir/cmd_cd.s \
sh/cmd/dir/cmd_ls.s \
sh/cmd/dir/cmd_mkdir.s \
sh/cmd/dir/cmd_rmdir.s

# Driver
SRCS_DRV = \
drv/ata/ata_get_sect.s \
drv/ata/ata_read_sect.s \
drv/ata/ata_write_sect.s \
\
drv/disk/disk_data.s \
drv/disk/disk_read_fsp.s \
drv/disk/disk_write_fsp.s \
drv/disk/disk_read_dpi.s \
drv/disk/disk_write_dpi.s \
drv/disk/disk_set_dpi.s \
drv/disk/disk_load_dpi.s \
\
drv/ps2/ps2_chk_sc_set.s \
drv/ps2/ps2_init.s \
drv/ps2/ps2_xlate_off.s \
drv/ps2/ps2_read_sc.s \
\
drv/kbd/kbd.s \
drv/kbd/kbd_data.s \
drv/kbd/kbd_keymap.s \
drv/kbd/kbd_upd_mflg.s \
drv/kbd/kbd_sctokc.s \
drv/kbd/kbd_key_cr.s \
drv/kbd/kbd_key_bs.s \
drv/kbd/kbd_key_up.s \
drv/kbd/kbd_key_down.s \
drv/kbd/kbd_key_left.s \
drv/kbd/kbd_key_right.s \
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
drv/disp/disp_shr_cl.s \
drv/disp/disp_shl_cl.s

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
lib/mem/mem_cmp.s \
lib/mem/mem_cpy.s \
lib/mem/mem_set.s \
lib/mem/mem_size.s

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
