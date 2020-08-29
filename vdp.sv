`timescale 10ns/10ps

/*TOP/         MIDDLE/      BOTTOM/      (SCREEN HOLES)
BASE  FIRST 40     SECOND 40    THIRD 40     UNUSED 8
ADDR  #  RANGE     #  RANGE     #  RANGE     RANGE
$400  00 $400-427  08 $428-44F  16 $450-477  $478-47F
$480  01 $480-4A7  09 $4A8-4CF  17 $4D0-4F7  $4F8-4FF
$500  02 $500-527  10 $528-54F  18 $550-577  $578-57F
$580  03 $580-5A7  11 $5A8-5CF  19 $5D0-5F7  $5F8-5FF
$600  04 $600-627  12 $628-64F  20 $650-677  $678-67F
$680  05 $680-6A7  13 $6A8-6CF  21 $6D0-6F7  $6F8-6FF
$700  06 $700-727  14 $728-74F  22 $750-777  $778-77F
$780  07 $780-7A7  15 $7A8-7CF  23 $7D0-7F7  $7F8-7FF */

module vdp (
    input           CLOCK_50,
    input           clk,
    input           res,
    output  logic   [7:0]VGA_B,
    output  logic   VGA_BLANK_N,    // to D2A chip, active low
    output  logic   VGA_CLK,        // latch the RGBs and put 'em on the DACs
    output  logic   [7:0]VGA_G,
    output  logic   VGA_HS,         // DB19 pin, active low
    output  logic   [7:0]VGA_R,
    output  logic   VGA_SYNC_N,     // to D2A chip, active low
    output  logic   VGA_VS,         // DB19 pin, active low
    output  logic   [15:0]txt_adr,      // XXX for now we reach out
    input           [7:0]txt_q);

logic   [23:0] vram_d;
logic   [15:0] vram_wadr;
logic   [23:0] vram_q;
logic   [15:0] vram_radr;
logic   [7:0] crom_q;
logic   [2:0] x7;
logic   [5:0] x40;
logic   [3:0] y8;
logic   [4:0] y24;

vram #(24,16) vram (
    .d              (vram_d),
    .w_adr          (vram_wadr),
    .we             (1'd1),
    .r_clk          (CLOCK_50),
    .w_clk          (CLOCK_50),
    .q              (vram_q),
    .r_adr          (vram_radr));

crom #(8,11) crom (
    .adr            ({txt_q[7:0], y8[2:0]}),
    .clk            (CLOCK_50),
    .q              (crom_q));

vga vga (
    .CLOCK_50,
    .d              (vram_q),
    .adr            (vram_radr),
    .VGA_B          (VGA_B),
    .VGA_BLANK_N    (VGA_BLANK_N),        // to D2A chip, active low
    .VGA_CLK        (VGA_CLK),            // latch the RGBs and put 'em on the DACs
    .VGA_G          (VGA_G),
    .VGA_HS         (VGA_HS),             // DB19 pin, active low
    .VGA_R          (VGA_R),
    .VGA_SYNC_N     (VGA_SYNC_N),         // to D2A chip, active low
    .VGA_VS         (VGA_VS));            // DB19 pin, active low

always @ (posedge clk, negedge res) begin
    if (!res) begin
        vram_wadr = 0; //last pixel
        txt_adr = 16'h400;
        x7 = 0;
        x40 = 0;
        y8 = 0;
        y24 = 0;
    end else begin
        x7++;
        if (x7 == 3'd7) begin
            x7 = 0;
            x40++;
            txt_adr++;
        end
        if (x40 == 6'd40) begin
            x40 = 0;
            y8++;
            if (y8 != 4'd8) begin
            case (txt_adr)
                16'h428 : txt_adr = 16'h400;
                16'h4a8 : txt_adr = 16'h480;
                16'h528 : txt_adr = 16'h500;
                16'h5a8 : txt_adr = 16'h580;
                16'h628 : txt_adr = 16'h600;
                16'h6a8 : txt_adr = 16'h680;
                16'h728 : txt_adr = 16'h700;
                16'h7a8 : txt_adr = 16'h780;
                16'h450 : txt_adr = 16'h428;
                16'h4d0 : txt_adr = 16'h4a8;
                16'h550 : txt_adr = 16'h528;
                16'h5d0 : txt_adr = 16'h5a8;
                16'h650 : txt_adr = 16'h628;
                16'h6d0 : txt_adr = 16'h6a8;
                16'h750 : txt_adr = 16'h728;
                16'h7d0 : txt_adr = 16'h7a8;
                16'h478 : txt_adr = 16'h450;
                16'h4f8 : txt_adr = 16'h4d0;
                16'h578 : txt_adr = 16'h550;
                16'h5f8 : txt_adr = 16'h5d0;
                16'h678 : txt_adr = 16'h650;
                16'h6f8 : txt_adr = 16'h6d0;
                16'h778 : txt_adr = 16'h750;
                16'h7f8 : txt_adr = 16'h7d0;
            endcase
            end
        end
        if (y8 == 4'd8) begin
            y8 = 0;
            y24++;
            case (txt_adr)
                16'h428 : txt_adr = 16'h480;
                16'h4a8 : txt_adr = 16'h500;
                16'h528 : txt_adr = 16'h580;
                16'h5a8 : txt_adr = 16'h600;
                16'h628 : txt_adr = 16'h680;
                16'h6a8 : txt_adr = 16'h700;
                16'h728 : txt_adr = 16'h780;
                16'h7a8 : txt_adr = 16'h428;
                16'h450 : txt_adr = 16'h4a8;
                16'h4d0 : txt_adr = 16'h528;
                16'h550 : txt_adr = 16'h5a8;
                16'h5d0 : txt_adr = 16'h628;
                16'h650 : txt_adr = 16'h6a8;
                16'h6d0 : txt_adr = 16'h728;
                16'h750 : txt_adr = 16'h7a8;
                16'h7d0 : txt_adr = 16'h450;
                16'h478 : txt_adr = 16'h4d0;
                16'h4f8 : txt_adr = 16'h550;
                16'h578 : txt_adr = 16'h5d0;
                16'h5f8 : txt_adr = 16'h650;
                16'h678 : txt_adr = 16'h6d0;
                16'h6f8 : txt_adr = 16'h750;
                16'h778 : txt_adr = 16'h7d0;
                16'h7f8 : txt_adr = 16'h400;
            endcase
        end
        if (y24 == 5'd24) begin
            y24 = 0;
        end

        vram_wadr++;
        if (vram_wadr == 280 * 192)
            vram_wadr = 0;
    end
end //always

always @ (negedge clk) begin
    if (crom_q[3'd6-x7] == 1)
        vram_d = 24'hffffff;
    else
        vram_d = 24'h000000;
end //case

endmodule
