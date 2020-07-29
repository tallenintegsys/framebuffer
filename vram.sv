`timescale 10ns/10ps
// Quartus Prime Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// separate read/write clocks

module vram
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
    input [(DATA_WIDTH-1):0] d,
    input [(ADDR_WIDTH-1):0] r_adr, w_adr,
    input we, r_clk, w_clk,
    output reg [(DATA_WIDTH-1):0] q
);

    initial $readmemh("test_pattern8.txt", ram, 0, 53759);

    // Declare the RAM variable
    reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

    always @ (posedge w_clk)
    begin
        // Write
        if (we)
            ram[w_adr] <= d;
    end

    always @ (posedge r_clk)
    begin
        // Read
        q <= ram[r_adr];
    end
endmodule
