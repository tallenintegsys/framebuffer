`timescale 10ns/10ps

module vdp (
	input CLOCK_50,
	output [7:0]VGA_B,
	output VGA_BLANK_N, // to D2A chip, active low
	output VGA_CLK, // latch the RGBs and put 'em on the DACs
	output [7:0]VGA_G,
	output VGA_HS, // DB19 pin, active low
	output [7:0]VGA_R,
	output VGA_SYNC_N, // to D2A chip, active low
	output VGA_VS); // DB19 pin, active low

	wire [23:0] vram_q;
	wire [15:0] vram_radr;
	logic vram_wclk;
	logic [15:0] vram_wadr;
	logic vram_we;
	logic [23:0] vram_d;
	logic [10:0] crom_adr;
	logic [7:0] crom_q;

vram #(24,16) vram (
	vram_d,
	vram_radr,
	vram_wadr,
	vram_we,
	CLOCK_50,
	vram_wclk,
	vram_q);

crom #(8,11) crom (
	crom_adr,
	CLOCK_50,
	crom_q);

vga vga (
	CLOCK_50,
	vram_q,
	vram_radr,
	VGA_B,
	VGA_BLANK_N, // to D2A chip, active low
	VGA_CLK, // latch the RGBs and put 'em on the DACs
	VGA_G,
	VGA_HS, // DB19 pin, active low
	VGA_R,
	VGA_SYNC_N, // to D2A chip, active low
	VGA_VS); // DB19 pin, active low

endmodule
