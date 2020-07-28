`timescale 10ns/10ps
module vdp_tb;

	// Input Ports
	logic CLOCK_50;

	// Output Ports
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic [7:0] VGA_G;
	logic VGA_HS;
	logic [7:0] VGA_R;
	logic VGA_SYNC_N;
	logic VGA_VS;

	logic rst;
	logic fb_wclk;
	logic [15:0] fb_wadr;
	logic fb_we;
	logic [23:0] fb_d;

initial begin
	$dumpfile("vdp.vcd");
	$dumpvars(0, uut);
	//$dumpoff;
	CLOCK_50 = 0;
	//#100000 
	//$dumpon;
	//#2000000
	#2000000
	$finish;
end

always begin
	#1 CLOCK_50 = !CLOCK_50;
end

vdp uut (
	CLOCK_50,
	fb_wclk,
	fb_wadr,
	fb_we,
	fb_d,
	VGA_B,
	VGA_BLANK_N, // redundant if RG&B are 0?
	VGA_CLK, // latch the RGBs and put 'em on the DACs
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N, //sync on green???
	VGA_VS);

endmodule
