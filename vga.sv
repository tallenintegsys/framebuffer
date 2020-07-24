`timescale 10ns/10ps

module vga (
	input CLOCK_50,
	output reg [7:0]VGA_B,
	output bit VGA_BLANK_N, // to D2A chip, active low
	output bit VGA_CLK, // latch the RGBs and put 'em on the DACs
	output reg [7:0]VGA_G,
	output bit VGA_HS, // DB19 pin, active low
	output reg [7:0]VGA_R,
	output bit VGA_SYNC_N, // to D2A chip, active low
	output bit VGA_VS); // DB19 pin, active low

logic [9:0] h_counter;
logic [9:0] v_counter;
logic [23:0] fb_d;
logic [16:0] fb_adr;
logic [23:0] fb_q;

assign fb_adr = h_counter + v_counter * 17'd200;

single_port_ram #(24, 17) framebuffer (fb_d, fb_adr, CLOCK_50, 1'd1, fb_q);

//this stuff should be in a reset block
initial begin
	h_counter = 0;
	v_counter = 0;
	VGA_HS = 1'd1;
	VGA_VS = 1'd1;
	VGA_SYNC_N = 1'd1;
	VGA_BLANK_N = 1'd1;
	VGA_SYNC_N = 0; //no sync on green
end
/*
640x480, 60Hz	25.175	640	16	96	48	480	11	2	31
*/

always @ (posedge CLOCK_50) begin
	VGA_CLK = ~VGA_CLK; //25MHz
end

always @ (posedge VGA_CLK) begin
	h_counter++;
	if (h_counter == 640) begin //hfront porch start
		VGA_BLANK_N = 0; //disable RGB DACs
	end
	if (h_counter == 656) begin //hfront porch end
		VGA_HS = 0; //hsync start
	end
	if (h_counter == 752) begin //hback porch start
		VGA_HS = 1; //hsync end
	end
	if (h_counter == 800) begin //hback porch end
		h_counter = 0;
		v_counter++;
		if (v_counter <= 480) //are we in vertical blanking?
			VGA_BLANK_N = 1; //enable RGB DACs
	end
	if (v_counter == 480) begin //vfront porch start
		VGA_BLANK_N = 0; //disable RGB DACs
	end
	if (v_counter == 491) begin //vfront porch end
		VGA_VS = 0; //vsync start
	end
	if (v_counter == 493) begin //vsync pulse end
		VGA_VS = 1; //vsync end
	end
	if (v_counter == 524) begin //vback porch end
		v_counter = 0;
		VGA_BLANK_N = 1; //enable RGB DACs
	end
	VGA_R = fb_q[23:16];
	VGA_G = fb_q[15:8];
	VGA_B = fb_q[7:0];
end
endmodule
