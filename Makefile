ALTERA=$(HOME)/altera/13.1/quartus/bin/
INTEL=$(HOME)/intelFPGA_lite/20.1/quartus/bin/
MAP=$(INTEL)quartus_map
FIT=$(INTEL)quartus_fit
ASM=$(INTEL)quartus_asm
STA=$(INTEL)quartus_sta
EDA=$(INTEL)quartus_eda
PGM=$(ALTERA)quartus_pgm
modules= framebuffer.sv vdp.sv vga.sv vram.sv crom.sv
VFLAGS= -Wall -g2012

all: sim

.PHONY: syn sim pgm clean
syn:
	$(MAP) --read_settings_files=on --write_settings_files=off framebuffer -c framebuffer
	$(FIT) --read_settings_files=off --write_settings_files=off framebuffer -c framebuffer
	$(ASM) --read_settings_files=off --write_settings_files=off framebuffer -c framebuffer
#	$(STA) framebuffer -c framebuffer
	$(EDA) --read_settings_files=off --write_settings_files=off framebuffer -c framebuffer

sim :
	iverilog $(VFLAGS) framebuffer_tb.sv $(modules)
	./a.out

pgm :
	$(PGM) -c 1 --mode=JTAG -o 'p;output_files/framebuffer.sof'

clean:
	rm *.vcd *.bak a.out
