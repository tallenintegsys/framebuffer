`timescale 10ns/10ps

module vdp (
    input           CLOCK_50,
    output  logic   [7:0]VGA_B,
    output  logic   VGA_BLANK_N, // to D2A chip, active low
    output  logic   VGA_CLK, // latch the RGBs and put 'em on the DACs
    output  logic   [7:0]VGA_G,
    output  logic   VGA_HS, // DB19 pin, active low
    output  logic   [7:0]VGA_R,
    output  logic   VGA_SYNC_N, // to D2A chip, active low
    output  logic   VGA_VS); // DB19 pin, active low

    wire    [15:0]  vram_radr;
    wire    [23:0]  vram_d;
    wire    [23:0]  vram_q;
    logic           vram_we;
    logic   [15:0]  vram_wadr;
    logic   [10:0]  crom_adr;
    logic   [7:0]   crom_q;
    logic   [15:0]  step;

    assign vram_d = crom_q;

vram #(24,16) vram (
    .d      (vram_d),
    .r_adr      (vram_radr),
    .w_adr      (vram_wadr),
    .we     (vram_we),
    .r_clk      (CLOCK_50),
    .w_clk      (CLOCK_50),
    .q      (vram_q));

crom #(8,11) crom (
    .adr        (crom_adr),
    .clk        (CLOCK_50),
    .q      (crom_q));

vga vga (
    .CLOCK_50,
    .d      (vram_q),
    .adr        (vram_radr),
    .VGA_B,
    .VGA_BLANK_N,                       // to D2A chip, active low
    .VGA_CLK,                           // latch the RGBs and put 'em on the DACs
    .VGA_G,
    .VGA_HS,                            // DB19 pin, active low
    .VGA_R,
    .VGA_SYNC_N,                        // to D2A chip, active low
    .VGA_VS);                           // DB19 pin, active low

always @ (posedge CLOCK_50) begin
    step++;
    case (step)
    1000: crom_adr <= 11'h2a0;
    1001: vram_wadr <= 16'd100;
    1002: vram_we <= 0;
    1003: vram_we <= 1;
    1100: crom_adr <= 11'h248;
    1200: crom_adr <= 11'h268;
    endcase
end
endmodule
