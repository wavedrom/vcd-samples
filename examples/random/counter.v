module counter (
  output reg [7:0] out,
  input clk, rstn
);

always @(posedge clk or negedge rstn)
  if (!rstn)
    out <= 8'b0;
  else
    out <= out + 1;

endmodule
