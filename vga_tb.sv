`timescale 10ns/10ps
module vga_tb;

	// Input Ports
	reg		CLOCK_50;

	// Output Ports
	reg [7:0] VGA_B;
	bit VGA_BLANK_N;
	bit VGA_CLK;
	reg [7:0] VGA_G;
	bit VGA_HS;
	reg [7:0] VGA_R;
	bit VGA_SYNC_N;
	bit VGA_VS;

	bit rst;

initial begin
	$dumpfile("framebuffer.vcd");
	$dumpvars(0, uut);
	//$dumpoff;
	CLOCK_50 = 0;
	//#100000 
	//$dumpon;
	#2000000
	$finish;
end

always begin
	#1 CLOCK_50 = !CLOCK_50;
end

vga uut (
	CLOCK_50,
	VGA_B,
	VGA_BLANK_N, // redundant if RG&B are 0?
	VGA_CLK, // latch the RGBs and put 'em on the DACs
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N, //sync on green???
	VGA_VS);

endmodule
