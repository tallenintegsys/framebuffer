module vga (
	input CLOCK_50,
	output reg [7:0]VGA_B,
	output bit VGA_BLANK_N, // redundant if RG&B are 0?
	output bit VGA_CLK, // latch the RGBs and put 'em on the DACs
	output reg [7:0]VGA_G,
	output bit VGA_HS,
	output reg [7:0]VGA_R,
	output bit VGA_SYNC_N, //sync on green???
	output bit VGA_VS);

logic [6:0] counter_10;
logic [8:0] h_counter;
logic [9:0] v_counter;
logic [23:0] framebuffer [200*600-1:0]; //200 x 600

initial begin
	counter_10 = 0;
	h_counter = 0;
	v_counter = 0;
	$readmemh("screenshot.txt", framebuffer);
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
		VGA_HS = 1; //hsync start
		VGA_SYNC_N = 1; //not sure about this
	end
	if (h_counter == 242) begin
		//hsync pulse stop, hback porch start
		VGA_HS = 0; //hsync end
		VGA_SYNC_N = 0; //not sure about this
	end
	if (h_counter == 264) begin
		//hback porch end
		h_counter = 0;
		v_counter++;
		VGA_BLANK_N = 1; //re-enable RG&B ?
	end
	if (v_counter == 600) begin
		//front porch start
		VGA_BLANK_N = 0; //make RG&B 0?
	end
	if (v_counter == 601) begin
		//vfront porch end, vsync pulse start
		VGA_VS = 1; //vsync start
	end
	if (v_counter == 605) begin
		//vsync pulse end, vback porch start
		VGA_VS = 0; //vsync end
	end
	if (v_counter == 628) begin
		//vback porch end
		v_counter = 0;
		VGA_BLANK_N = 1; //re-enable RG&B ?
	end
	VGA_R = framebuffer[h_counter+v_counter*200][23:16];
	VGA_G = framebuffer[h_counter+v_counter*200][15:8];
	VGA_B = framebuffer[h_counter+v_counter*200][7:0];
end
endmodule
