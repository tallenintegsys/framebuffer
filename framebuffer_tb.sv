`timescale 10ns/10ps
module vdp_tb;

    // Input Ports
    logic CLOCK_50;

    // Output Ports
    logic [7:0] VGA_B;
    logic VGA_BLANK_N;
    logic VGA_CLK;
    logic [7:0] VGA_G;
    logic VGA_HS;
    logic [7:0] VGA_R;
    logic VGA_SYNC_N;
    logic VGA_VS;

    logic rst;
    logic fb_wclk;
    logic [15:0] fb_wadr;
    logic fb_we;
    logic [23:0] fb_d;
    string text = "@ABCDE HELLO WORLD";
    logic [7:0][40:0] textbuf;
    logic [15:0] cpu_adr;
    logic [7:0] txt;
    logic reset;

    initial txt = 0;

initial begin
    $dumpfile("vdp.vcd");
    $dumpvars(0, uut);
    for (int i = 0; i < 40; i++) begin
      textbuf[i] = 8'd0;//text[i];
    end
    //$dumpoff;
    CLOCK_50 = 0;
    reset <= 0;
    #10
    reset <= 1;
    #1000
    reset <= 0;
    //#100000
    //$dumpon;
    //#2000000
    #200000
    $finish;
end

always begin
    #1 CLOCK_50 = !CLOCK_50;
    txt = textbuf[cpu_adr];
end

framebuffer uut (
    .CLOCK_50,
    .reset,
    .VGA_B,
    .VGA_BLANK_N, // redundant if RG&B are 0?
    .VGA_CLK, // latch the RGBs and put 'em on the DACs
    .VGA_G,
    .VGA_HS,
    .VGA_R,
    .VGA_SYNC_N, //sync on green???
    .VGA_VS);

endmodule
