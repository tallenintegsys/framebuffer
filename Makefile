PGM=$(HOME)/altera/13.1/quartus/bin/quartus_pgm
modules= vdp.sv vga.sv vram.sv crom.sv
VFLAGS= -Wall -g2012

all: sim

.PHONY: syn sim pgm clean
syn :
	iverilog $(VFLAGS) -o output_files/framebuffer $(modules)

sim :
	iverilog $(VFLAGS) vdp_tb.sv $(modules)
	./a.out

pgm :
	$(PGM) -c 1 --mode=JTAG -o 'p;output_files/framebuffer.sof'

clean:
	rm *.vcd *.bak a.out
