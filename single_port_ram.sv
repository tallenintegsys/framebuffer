`timescale 10ns/10ps
// Quartus Prime Verilog Template
// Single port RAM with single read/write address 

module single_port_ram 
#(parameter D_WIDTH=8, parameter A_WIDTH=16)
(
	input [(D_WIDTH-1):0] d,
	input [(A_WIDTH-1):0] adr,
	input clk, we,
	output [(D_WIDTH-1):0] q
);

	initial $readmemh("test_pattern8.txt", ram, 0, 53759);

	// Declare the RAM variable
	bit [D_WIDTH-1:0] ram[2**A_WIDTH-1:0];

	// Variable to hold the registered read address
	reg [A_WIDTH-1:0] addr_reg;

	always @ (posedge clk)
	begin
		// Write
		if (!we)
			ram[adr] <= d;
		// Read
		addr_reg <= adr;
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = ram[addr_reg];

endmodule
