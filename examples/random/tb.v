`timescale 10ns/10ns

module tb;
  reg rstn = 0;
  initial begin
     $dumpfile("random.vcd");
     $dumpvars(0, tb);
     # 8 rstn = 1;
     # 32 $finish;
  end

  reg clk = 1;
  always #1 clk = !clk;

  reg [31:0] seed = 42;
  reg [7:0] value;
  always #2 value = $random(seed);

endmodule
