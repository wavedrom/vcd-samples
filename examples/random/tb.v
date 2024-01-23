`timescale 10ns/1ns

module tb;
  reg rstn = 0;
  initial begin
     $dumpfile("random.vcd");
     $dumpvars(0, tb);
     # 8 rstn = 1;
     # 32 $finish;
  end

  reg clk = 1;
  always #0.5 clk = !clk;

  wire [7:0] value;
  counter u0 (value, clk, rstn);

  reg [31:0] seed = 2;
  reg [7:0] rnd;
  always #1 rnd = $random(seed);

endmodule
