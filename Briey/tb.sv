`timescale 1ns/1ns

module tb;
  reg reset = 1;
  integer duration = 1000;
  reg [8*64:1] vcdname = "dump.vcd";
  initial begin
    $value$plusargs("vcdname=%s", vcdname);
    $value$plusargs("duration=%d", duration);
    $dumpfile(vcdname);
    $dumpvars(0, tb);
    # 10 reset = 0;
    # duration $finish;
  end

  reg clock = 1;
  always #2 clock = !clock; // 250MHz

  Briey u0 (
    .io_coreInterrupt(1'b0),
    .io_axiClk(clock),
    .io_vgaClk(clock),
    .io_asyncReset(reset)
  );

// Pipeline Probes
wire [31:0] dc_pc = u0.axi_core_cpu.decode_PC;
wire [31:0] ex_pc = u0.axi_core_cpu.execute_PC;
wire [31:0] mm_pc = u0.axi_core_cpu.memory_PC;
wire [31:0] wb_pc = u0.axi_core_cpu.writeBack_PC;

wire dc_go = u0.axi_core_cpu.decode_arbitration_isValid;
wire ex_go = u0.axi_core_cpu.execute_arbitration_isValid;
wire mm_go = u0.axi_core_cpu.memory_arbitration_isValid;
wire wb_go = u0.axi_core_cpu.writeBack_arbitration_isValid;

endmodule
