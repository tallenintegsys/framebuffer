`timescale 10ns/10ps

module vdp (
    input           CLOCK_50,
    output  logic   [7:0]VGA_B,
    output  logic   VGA_BLANK_N,    // to D2A chip, active low
    output  logic   VGA_CLK,        // latch the RGBs and put 'em on the DACs
    output  logic   [7:0]VGA_G,
    output  logic   VGA_HS,         // DB19 pin, active low
    output  logic   [7:0]VGA_R,
    output  logic   VGA_SYNC_N,     // to D2A chip, active low
    output  logic   VGA_VS/*,         // DB19 pin, active low
    output  logic   [15:0]cpu_adr,  // XXX for now we reach out
    input   logic   [7:0]txt*/);

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
    logic   [7:0]   txtbuf[0:960];  //XXX temporary
    logic   [15:0]  cpu_adr;        //XXX this will live
    logic   [7:0]   txt;            //XXX in main RAM
    logic   [2:0]   chary;

    assign cpu_adr = x_txt;// it's at $400 on Apple II + 16'h400;
    assign crom_adr = {txt[6:0], chary}; //XXX the second line of the char
    assign vram_wadr = x_pos + y_pos*280;
    assign txt = txtbuf[cpu_adr];
    initial begin
        x_pos = 0;
        y_pos = 0;
        chary = 0;
        x_txt_cnt = 0;
        x_txt = 0;
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
    .VGA_B,
    .VGA_BLANK_N,                       // to D2A chip, active low
    .VGA_CLK,                           // latch the RGBs and put 'em on the DACs
    .VGA_G,
    .VGA_HS,                            // DB19 pin, active low
    .VGA_R,
    .VGA_SYNC_N,                        // to D2A chip, active low
    .VGA_VS);                           // DB19 pin, active low

always @ (posedge CLOCK_50) begin
    x_pos <= x_pos + 1;
    if (x_pos >= 279) begin
        x_pos <= 0;
        x_txt <= 0 + 40 * y_pos[7:3];
        x_txt_cnt <= 0;
        y_pos <= y_pos + 1;
        chary <= chary + 1;
    end else begin
        if (x_txt_cnt == 6) begin
            x_txt_cnt <= 0;
            x_txt <= x_txt + 1;
        end else
            x_txt_cnt <= x_txt_cnt + 1;
    end

    if (y_pos >= 192) begin
        y_pos <= 0;
        chary <= 0;
        x_txt <= 0;
    end


    if (crom_q[3'd6-x_txt_cnt] == 1)
        vram_d <= 24'hffffff;
    else
        vram_d <= 0;
end
endmodule
