# SPDX-License-Identifier: Apache-2.0
#
# Copyright 2025-2026 Facooya and Fanone Facooya

# config
FAYOS_IMG = ./build/fayos.img
BOOT_BIN = ./build/boot.bin
KERN_BIN = ./build/kern.bin
TOT_SECT_CNT = 20480

# boot
SRC_BOOT = boot/boot.s
OBJ_BOOT = $(SRC_BOOT:%.s=./build/%.o)

# kernel
SRCS_KERN = \
kern/kern.s \
kern/kern_data.s \
\
kern/mem/mem_data.s \
kern/mem/mem_alloc.s \
kern/mem/mem_free.s \
\
kern/dbg/dbg_arg_ccv.s \
kern/dbg/dbg_path_cv.s \
kern/dbg/dbg_curs.s \
kern/dbg/dbg_sbuf.s \
kern/dbg/dbg_trace.s \
kern/dbg/dbg_utils.s \
kern/dbg/dbg_fsp.s \
\
kern/dbg/num/dbg_num.s \
kern/dbg/num/dbg_reg.s

# file system
SRCS_FS = \
fs/fs.s \
fs/superblock.s \
fs/bitmap.s \
fs/inode.s \
fs/dentry.s \
fs/path.s \
fs/fsp.s \

# shell
SRCS_SH = \
sh/cwd.s \
sh/args.s \
sh/prompt.s \
sh/execute.s \
sh/history.s \
\
sh/cmd/command.s \
sh/cmd/test.s \
sh/cmd/echo.s \
sh/cmd/date.s \
sh/cmd/help.s \
sh/cmd/clear.s \
\
sh/cmd/cat.s \
sh/cmd/ls.s \
sh/cmd/pwd.s \
sh/cmd/cd.s \
sh/cmd/touch.s \
sh/cmd/rm.s \
sh/cmd/mkdir.s \
sh/cmd/rmdir.s

# driver
SRCS_DRV = \
drv/ata/ata_data.s \
drv/ata/ata_init.s \
drv/ata/ata_get_sect.s \
drv/ata/ata_read_sect.s \
drv/ata/ata_write_sect.s \
\
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
\
drv/kbd/kbd_data.s \
drv/kbd/kbd_run.s \
drv/kbd/kbd_proc.s \
drv/kbd/kbd_upd_mflg.s \
drv/kbd/kbd_conv_kc.s \
drv/kbd/kbd_hdl_cr.s \
drv/kbd/kbd_hdl_bs.s \
drv/kbd/kbd_hdl_up.s \
drv/kbd/kbd_hdl_down.s \
drv/kbd/kbd_hdl_left.s \
drv/kbd/kbd_hdl_right.s \
\
drv/vga/vga_data.s \
drv/vga/vga_init.s \
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
drv/disp/disp_shl_cl.s \
\
drv/disk.s \
drv/rtc.s

# interrupt
SRCS_INT = \
int/interrupt.s \
int/isr.s

# library
SRCS_LIB = \
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
lib/mem/mem_size.s \
\
lib/regex/regex_alpha.s \
lib/regex/regex_name.s \
\
lib/conv/ub8_h_to_d.s \
lib/conv/ub8_d_to_c.s

# kernel group
SRCS_GROUP_KERN = \
$(SRCS_KERN) \
$(SRCS_FS) \
$(SRCS_SH) \
$(SRCS_DRV) \
$(SRCS_INT) \
$(SRCS_LIB)

# objects
OBJS_KERN = $(SRCS_GROUP_KERN:%.s=./build/%.o)

# { command
all: $(FAYOS_IMG)

$(FAYOS_IMG): $(BOOT_BIN) $(KERN_BIN) | ./build/
	dd if=/dev/zero of=$(FAYOS_IMG) bs=512 count=$(TOT_SECT_CNT)
	dd if=$(BOOT_BIN) of=$(FAYOS_IMG) bs=512 count=1 conv=notrunc
	dd if=$(KERN_BIN) of=$(FAYOS_IMG) bs=512 seek=16 conv=notrunc

$(BOOT_BIN): $(OBJ_BOOT) | ./build/
	ld -T ./boot/boot.lds -o $@ $^

$(KERN_BIN): $(OBJS_KERN) | ./build/
	ld -T ./kern/kern.lds -o $@ $^

$(OBJ_BOOT): $(SRC_BOOT) | ./build/
	mkdir -p $(dir $@)
	as --32 -Iboot -o $@ $^

./build/%.o: %.s | $(OBJ_BOOT)
	mkdir -p $(dir $@)
	as --32 -Iinc -o $@ $^

./build/:
	mkdir -p $@

clean:
	find ./build/ -name "*.bin" -delete
	find ./build/ -name "*.o" -delete
	find ./build/ -name "*.lock" -delete
	find ./build/ -name "bochslog" -delete
	find ./build/ -type d -empty -delete

clean_all: clean
	find ./build/ -name "*.img" -delete
	find ./build/ -type d -empty -delete
# }
