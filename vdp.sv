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
    logic   [9:0]   txt_adr;
    logic   [7:0]   charbit;
    logic   [7:0]   txtbuf[0:400];  //XXX temporary
    logic   [15:0]  cpu_adr;        //XXX this will live
    logic   [7:0]   txt;            //XXX in main RAM

    assign txt_adr = x_pos[8:3];
    assign cpu_adr = txt_adr;// it's at $400 on Apple II + 16'h400;
    assign crom_adr = {txt, y_pos[2:0]}; //XXX the second line of the char
    assign vram_wadr = x_pos + y_pos*280;
    assign txt = txtbuf[cpu_adr];
    initial begin
        x_pos = 0;
        y_pos = 0;
        for (int i = 0; i < 400; i++) begin
          txtbuf[i] = 8'd0;//text[i];
        end
        txtbuf[20] = "H" - 64;
        txtbuf[21] = "E" - 64;
        txtbuf[22] = "L" - 64;
        txtbuf[23] = "L" - 64;
        txtbuf[24] = "O" - 64;
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
        y_pos <= y_pos + 1;
    end
    if (y_pos >= 192)
        y_pos <= 0;

    //if (crom_q[3'd6-x_pos[2:0]] == 1)
    if (crom_q[3'd1<<x_pos[1:0]] == 1)
        vram_d <= 24'hffffff;
    else
        vram_d <= 0;
end
endmodule
