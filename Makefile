PGM=$(HOME)/altera/13.1/quartus/bin/quartus_pgm
modules= vga.sv
VFLAGS= -Wall -g2012

all: syn

.PHONY: syn sim pgm clean
syn :
	iverilog $(VFLAGS) -o output_files/framebuffer $(modules)

sim :
	iverilog $(VFLAGS) vga_tb.sv $(modules)
	./a.out

pgm :
	$(PGM) -c 1 --mode=JTAG -o 'p;output_files/framebuffer.sof'

clean:
	rm *.vcd a.out
