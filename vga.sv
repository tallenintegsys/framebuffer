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

logic [9:0] h_counter; //visible + blanking
logic [9:0] v_counter; //visible + blanking
logic [23:0] fb_d;
logic [15:0] fb_adr;
logic [23:0] fb_q;
logic h_blank, v_blank;
logic v_advance;
logic reset;
logic [3:0]reset_counter;

single_port_ram #(24, 16) framebuffer (fb_d, fb_adr, CLOCK_50, 1'd1, fb_q);

//640x480, 60Hz	25.175	640	16	96	48	480	11	2	31

assign VGA_BLANK_N = h_blank & v_blank;
initial reset = 0;
initial reset_counter = 0;

always @ (posedge CLOCK_50) begin
	reset_counter++;
	if (reset_counter == 5) begin
		reset <= 1;
	end
	VGA_CLK <= ~VGA_CLK; //25MHz
	VGA_R <= fb_q[23:16];
	VGA_G <= fb_q[15:8];
	VGA_B <= fb_q[7:0];
end

always @ (posedge VGA_CLK) begin
if (reset == 0) begin //active low reset
	h_counter <= 0;
	v_counter <= 0;
	VGA_HS = 1'd1;
	VGA_VS = 1'd1;
	VGA_SYNC_N <= 0; //no sync on green
	h_blank <= 1'd1;
	v_blank <= 1'd1;
	fb_adr <= 0;
	v_advance = 0;
end else begin
	h_counter <= h_counter + 1;
	case (h_counter)
	639: begin //hfront porch start
		h_blank <= 0; //disable RGB DACs
	end
	655: begin //hfront porch end
		VGA_HS <= 0; //hsync start
		v_advance++;
		if (v_advance && (v_counter < 480)) begin
			fb_adr <= fb_adr - 320;
		end
	end
	751: begin //hback porch start
		VGA_HS <= 1'd1; //hsync end
	end
	800: begin //hback porch end
		h_blank <= 1'd1; //enable RGB DACs
		h_counter <= 0;
		v_counter++;
	end
	endcase
	if ((h_counter >= 0) && (h_counter < 640) && (v_counter < 480)) begin //visible range
		if (!h_counter[0]) begin
			fb_adr <= fb_adr + 1;
		end
	end
	//fb_adr = x_counter * 280 / 640 + y_counter * 192 / 480;

	case (v_counter)
	480: begin //vfront porch start
		v_blank <= 0; //disable RGB DACs
		fb_adr <= 0;
	end
	491: begin //vfront porch end
		VGA_VS <= 0; //vsync start
	end
	493: begin //vsync pulse end
		VGA_VS <= 1'd1; //vsync end
	end
	524: begin //vback porch end
		v_blank <= 1'd1; //enable RGB DACs
		v_counter <= 0;
		v_advance = 0;
	end
	endcase
end //if reset
end //always
endmodule
