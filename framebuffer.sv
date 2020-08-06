`timescale 10ns/10ps
module framebuffer
(
    input           CLOCK_50,
    output  logic   [7:0]VGA_B,
    output  logic   VGA_BLANK_N,    // to D2A chip, active low
    output  logic   VGA_CLK,        // latch the RGBs and put 'em on the DACs
    output  logic   [7:0]VGA_G,
    output  logic   VGA_HS,         // DB19 pin, active low
    output  logic   [7:0]VGA_R,
    output  logic   VGA_SYNC_N,     // to D2A chip, active low
    output  logic   VGA_VS);        // DB19 pin, active low

logic [7:0]     d;
logic [15:0]    adr;
logic [7:0]     txtbuf[0:960];

initial begin
    for (int i = 0; i < 960; i++) begin
        txtbuf[i] = 8'ha0;
    end
    txtbuf[0] = "<" - 64;
    txtbuf[15] = "H" - 64;
    txtbuf[16] = "E" - 64;
    txtbuf[17] = "L" - 64;
    txtbuf[18] = "L" - 64;
    txtbuf[19] = "O" - 64;
    txtbuf[20] = " " - 64;
    txtbuf[21] = "W" - 64;
    txtbuf[22] = "O" - 64;
    txtbuf[23] = "R" - 64;
    txtbuf[24] = "L" - 64;
    txtbuf[25] = "D" - 64;
    txtbuf[39] = ">" - 64;
    txtbuf[920] = "<" - 64;
    txtbuf[940] = "_" - 64;
    txtbuf[959] = ">" - 64;
    for (int i = 0; i < 255; i++)
        txtbuf[400+i] = i;
end

vdp vdp(
    .CLOCK_50,
    .VGA_B (VGA_B),
    .VGA_BLANK_N,    // to D2A chip, active low
    .VGA_CLK,        // latch the RGBs and put 'em on the DACs
    .VGA_G (VGA_G),
    .VGA_HS,         // DB19 pin, active low
    .VGA_R (VGA_R),
    .VGA_SYNC_N,     // to D2A chip, active low
    .VGA_VS,         // DB19 pin, active low
    .cpu_adr (adr),  // XXX for now we reach out
    .txt (d));

endmodule
