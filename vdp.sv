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
    input           phi,
    input           [7:0]txt,
    input           reset,
    output  logic   [7:0]VGA_B,
    output  logic   VGA_BLANK_N,    // to D2A chip, active low
    output  logic   VGA_CLK,        // latch the RGBs and put 'em on the DACs
    output  logic   [7:0]VGA_G,
    output  logic   VGA_HS,         // DB19 pin, active low
    output  logic   [7:0]VGA_R,
    output  logic   VGA_SYNC_N,     // to D2A chip, active low
    output  logic   VGA_VS,         // DB19 pin, active low
    output  logic   [15:0]adr);  // XXX for now we reach out

    wire    [15:0]  vram_radr;
    wire    [23:0]  vram_q;
    logic           vram_we;
    logic   [23:0]  vram_d;
    logic   [15:0]  vram_wadr;
    logic   [10:0]  crom_adr;
    logic   [7:0]   crom_q;
    logic   [8:0]   x_pos;
    logic   [7:0]   y_pos;
    logic   [9:0]   x_txt;
    logic   [2:0]   x_txt_cnt;
    logic   [2:0]   chary;

    assign adr = {6'd0, x_txt} + 40 * y_pos[7:3] + 16'h400;// it's at $400 on Apple II + 16'h400;
    assign vram_wadr = x_pos + y_pos*280;

vram #(24,16) vram (
    .d              (vram_d),
    .r_adr          (vram_radr),
    .w_adr          (vram_wadr),
    .we             (1'd1),
    .r_clk          (CLOCK_50),
    .w_clk          (CLOCK_50),
    .q              (vram_q));

crom #(8,11) crom (
    .adr            (crom_adr),
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


always @ (posedge phi) begin
    if (!reset) begin
        x_pos <= 0;
        y_pos <= 0;
        chary <= 0;
        x_txt_cnt <= 0;
        x_txt <= 0;
    end else begin
        x_pos <= x_pos + 1;
        if (x_pos >= 279) begin //end of scanline
            x_pos <= 0;
            x_txt <= 0 + 40 * y_pos[7:3]; //8 scanlines per line of text
            x_txt_cnt <= 0;
            y_pos <= y_pos + 1;
            chary <= chary + 1;
        end else begin
            if (x_txt_cnt == 6) begin //end of text char cell
                x_txt_cnt <= 0; //first dot of
                x_txt <= x_txt + 1; //the next cell
            end else
                x_txt_cnt <= x_txt_cnt + 1; //next dot of this cell
        end
        if (y_pos >= 192) begin //last scan line
            y_pos <= 0;
            chary <= 0;
            x_txt <= 0;
        end

        crom_adr <= {txt[7:0], chary[2:0]}; //XXX the second line of the char

        if (crom_q[3'd6-x_txt_cnt] == 1'd1)
            vram_d <= 24'hffffff;
        else
            vram_d <= 0;
    end
end

always @ (posedge CLOCK_50) begin
end

endmodule
