`timescale 10ns/1ns

module tb;
  reg rstn = 0;
  integer duration = 10000;
  reg [8*64:1] vcdname = "dump.vcd";
  initial begin
    $value$plusargs("vcdname=%s", vcdname);
    $value$plusargs("duration=%d", duration);
    $dumpfile(vcdname);
    $dumpvars(0, tb);
    # 8 rstn = 1;
    # duration $finish;
  end

  reg clk = 1;
  always #0.5 clk = !clk;

  wire [63:0] value;
  counter u0 (.out(value), .clk(clk), .rstn(rstn));

  reg [64:0] seed = 2;
  reg [64:0] rnd;
  always #1 rnd = $random(seed);

endmodule
