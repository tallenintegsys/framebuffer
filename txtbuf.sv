`timescale 10ns/10ps

// Quartus Prime Verilog Template
// Single Port ROM

module txtbuf
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=16)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

initial begin
    for (int i = 16'h400; i < 16'h7f8; i++) begin
        rom[i] = 8'ha0;
    end
    rom[16'h400] = "<";
    rom[16'h40f] = "H";
    rom[16'h410] = "E";
    rom[16'h411] = "L";
    rom[16'h412] = "L";
    rom[16'h413] = "O";
    rom[16'h414] = " ";
    rom[16'h415] = "W";
    rom[16'h416] = "O";
    rom[16'h417] = "R";
    rom[16'h418] = "L";
    rom[16'h419] = "D";
    rom[16'h427] = ">";
    rom[16'h7d0] = "<";
    rom[16'h7e4] = "_";
    rom[16'h7f7] = ">";
    
    rom[16'h480] = "L";
    rom[16'h481] = "I";
    rom[16'h482] = "N";
    rom[16'h483] = "E";
    rom[16'h484] = " ";
    rom[16'h485] = "0";
    rom[16'h486] = "2";
    
    rom[16'h428] = "L";
    rom[16'h429] = "I";
    rom[16'h42a] = "N";
    rom[16'h42b] = "E";
    rom[16'h42c] = " ";
    rom[16'h42d] = "0";
    rom[16'h42e] = "9";
    for (int i = 0; i < 255; i++)
        rom[16'h450+i] = i;
end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule
