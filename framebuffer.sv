`timescale 10ns/10ps
module framebuffer
(   input           CLOCK_50,
    input           reset,
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
logic [15:0]    a;
logic [7:0]     txtbuf[1024:2040];
logic [2:0]     count;
logic           phi;

initial phi <= 0;
initial count <= 0;
assign a = adr;
assign d = txtbuf[a];

vdp vdp(
    .CLOCK_50,
    .clk (phi),
    .reset (reset),
    .VGA_B (VGA_B),
    .VGA_BLANK_N,    // to D2A chip, active low
    .VGA_CLK,        // latch the RGBs and put 'em on the DACs
    .VGA_G (VGA_G),
    .VGA_HS,         // DB19 pin, active low
    .VGA_R (VGA_R),
    .VGA_SYNC_N,     // to D2A chip, active low
    .VGA_VS,         // DB19 pin, active low
    .adr,  // XXX for now we reach out
    .txt (d));

always @ (posedge CLOCK_50) begin
    if (!reset) begin
        for (int i = 16'h400; i < 16'h7f8; i++) begin
            txtbuf[i] = 8'ha0;
        end
        txtbuf[16'h400] = "<";
        txtbuf[16'h40f] = "H";
        txtbuf[16'h410] = "E";
        txtbuf[16'h411] = "L";
        txtbuf[16'h412] = "L";
        txtbuf[16'h413] = "O";
        txtbuf[16'h414] = " ";
        txtbuf[16'h415] = "W";
        txtbuf[16'h416] = "O";
        txtbuf[16'h417] = "R";
        txtbuf[16'h418] = "L";
        txtbuf[16'h419] = "D";
        txtbuf[16'h427] = ">";
        txtbuf[16'h7d0] = "<";
        txtbuf[16'h7e4] = "_";
        txtbuf[16'h7f7] = ">";

        txtbuf[16'h480] = "L";
        txtbuf[16'h481] = "I";
        txtbuf[16'h482] = "N";
        txtbuf[16'h483] = "E";
        txtbuf[16'h484] = " ";
        txtbuf[16'h485] = "0";
        txtbuf[16'h486] = "2";

        txtbuf[16'h428] = "L";
        txtbuf[16'h429] = "I";
        txtbuf[16'h42a] = "N";
        txtbuf[16'h42b] = "E";
        txtbuf[16'h42c] = " ";
        txtbuf[16'h42d] = "0";
        txtbuf[16'h42e] = "9";
        for (int i = 0; i < 255; i++)
            txtbuf[16'h450+i] = i;

        count <= 0;
    end
    count <= count - 1;
    if (count == 0)
        phi <= ~phi;
end

endmodule
