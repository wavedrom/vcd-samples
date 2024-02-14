`timescale 10ns/1ns

module tb;
  reg treset = 1;
  initial begin
     $dumpfile("jtag.vcd");
     $dumpvars(0, tb);
     # 3 treset = 0;
     # 64 $finish;
  end

  reg [31:0] seed = 12;
  reg tms = 0;
  always #1 tms = $random(seed);

  reg tck = 1;
  always #0.5 tck = !tck;

  wire [3:0] jtagState;
  jtag u0 (.outState(jtagState), .tck(tck), .tms(tms), .treset(treset));

endmodule
