Random number generator

```bash
iverilog -g2005-sv -o sim counter.v tb.sv && vvp sim +duration=1000 +vcdname=dump1.vcd
```

https://vc.drom.io/?github=wavedrom/vcd-samples/trunk/examples/Briey/dump1.vcd&github=wavedrom/vcd-samples/trunk/examples/Briey/dump.waveql&github=wavedrom/vcd-samples/trunk/examples/Briey/demo.lst

Line: 2060

```
// Pipeline Probes
wire [31:0] dc_pc = axi_core_cpu.decode_PC;
wire [31:0] ex_pc = axi_core_cpu.execute_PC;
wire [31:0] mm_pc = axi_core_cpu.memory_PC;
wire [31:0] wb_pc = axi_core_cpu.writeBack_PC;

wire dc_go = axi_core_cpu.decode_arbitration_isValid;
wire ex_go = axi_core_cpu.execute_arbitration_isValid;
wire mm_go = axi_core_cpu.memory_arbitration_isValid;
wire wb_go = axi_core_cpu.writeBack_arbitration_isValid;
```