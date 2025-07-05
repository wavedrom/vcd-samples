module counter (
  output reg [63:0] out,
  input clk, rstn
);

always @(posedge clk or negedge rstn)
  if (!rstn)
    out <= 63'b0;
  else
    out <= out + 1;

endmodule
