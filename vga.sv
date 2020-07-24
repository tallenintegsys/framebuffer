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

logic [6:0] counter_10;
logic [8:0] h_counter;
logic [9:0] v_counter;
//logic [23:0] fb_d;
//logic [16:0] fb_adr;
//logic [23:0] fb_q;
//logic fb_rw;

//assign fb_adr = h_counter + v_counter * 17'd200;

//single_port_ram #(24, 8) framebuffer (fb_d, fb_adr, fb_rw, VGA_CLK, fb_q);

initial begin
	counter_10 = 0;
	h_counter = 0;
	v_counter = 0;
//	fb_rw = 1'd1;
	VGA_HS = 1'd1;
	VGA_VS = 1'd1;
	VGA_SYNC_N = 1'd1;
	VGA_BLANK_N = 1'd1;
	end

always @ (posedge CLOCK_50) begin
	counter_10++;
	if (counter_10 == 2)
		VGA_CLK = 1'd1;
	if (counter_10 == 5) begin
		counter_10 = 0;
		VGA_CLK = ~VGA_CLK; //10MHz
	end
end

always @ (posedge VGA_CLK) begin
	h_counter++;
	if (h_counter == 200) begin
		//hfront porch start
		VGA_BLANK_N = 0; //make RG&B 0?
	end
	if (h_counter == 210) begin
		//hfront porch end, hsync pluse start
		VGA_HS = 0; //hsync start
		VGA_SYNC_N = 0; //not sure about this
	end
	if (h_counter == 242) begin
		//hsync pulse stop, hback porch start
		VGA_HS = 1; //hsync end
		VGA_SYNC_N = 1; //not sure about this
	end
	if (h_counter == 264) begin
		//hback porch end
		h_counter = 0;
		v_counter++;
		if (v_counter <= 600) //are we in vertical blanking?
			VGA_BLANK_N = 1; //re-enable RG&B ?
	end
	if (v_counter == 600) begin
		//front porch start
		VGA_BLANK_N = 0; //make RG&B 0?
	end
	if (v_counter == 601) begin
		//vfront porch end, vsync pulse start
		VGA_VS = 0; //vsync start
	end
	if (v_counter == 605) begin
		//vsync pulse end, vback porch start
		VGA_VS = 1; //vsync end
	end
	if (v_counter == 628) begin
		//vback porch end
		v_counter = 0;
		VGA_BLANK_N = 1; //re-enable RG&B ?
	end
	VGA_R = 8'ha0; //fb_d[23:16];
	VGA_G = 8'h20; //fb_d[15:8];
	VGA_B = 8'h40; //fb_d[7:0];
end
endmodule
