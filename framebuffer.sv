`timescale 10ns/10ps
module framebuffer
(   input           CLOCK_50,
    input           [3:0] KEY,
    output  logic   [8:0] LEDG,
    output  logic   [17:0] LEDR,
    output  logic   [7:0] VGA_B,
    output  logic   VGA_BLANK_N,    // to D2A chip, active low
    output  logic   VGA_CLK,        // latch the RGBs and put 'em on the DACs
    output  logic   [7:0] VGA_G,
    output  logic   VGA_HS,         // DB19 pin, active low
    output  logic   [7:0] VGA_R,
    output  logic   VGA_SYNC_N,     // to D2A chip, active low
    output  logic   VGA_VS);        // DB19 pin, active low

logic [7:0]     d;
logic [15:0]    adr;
logic [15:0]    a;
logic [7:0]     txtbuf[1024:2040];
logic [2:0]    count;
logic           phi;
logic           res;

initial phi <= 0;
initial count <= 0;
assign a = adr;
assign res = KEY[0];
assign LEDG[8] = phi;
//assign LEDG[7:0] = count[15:8];
assign LEDR[15:0] = adr;

vdp vdp(
    .CLOCK_50,
    .clk (phi),
    .res (res),
    .VGA_B (VGA_B),
    .VGA_BLANK_N,    // to D2A chip, active low
    .VGA_CLK,        // latch the RGBs and put 'em on the DACs
    .VGA_G (VGA_G),
    .VGA_HS,         // DB19 pin, active low
    .VGA_R (VGA_R),
    .VGA_SYNC_N,     // to D2A chip, active low
    .VGA_VS,         // DB19 pin, active low
    .txt_adr (adr),  // XXX for now we reach out
    .txt_q (d));

txtbuf tbuf (
    .clk (CLOCK_50),
    .addr (adr),
    .q (d));

always @ (posedge CLOCK_50) begin
    if (!res) begin //reset
       count <= 0;
       phi <= 0;
   end else begin
       count <= count - 1;
       if (count == 0)
           phi++;
   end

end //always
endmodule
