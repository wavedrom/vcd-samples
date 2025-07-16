## Pipeline Viewer Demo

https://vc.drom.io/?github=wavedrom/vcd-samples/trunk/examples/Briey/dump1.vcd&github=wavedrom/vcd-samples/trunk/examples/Briey/dump.waveql&github=wavedrom/vcd-samples/trunk/examples/Briey/demo.lst

3 files needed for Pipeline View:
* `.vcd` - of simulation dump with pipeline probes
* `.waveql` - Waveform Query (signal list) file with correct DIZ RegExp
* `.lst` - Assembly listing from Object Dump

### Inserting Pipeline Probes into Verilog

https://github.com/wavedrom/vcd-samples/blob/trunk/examples/Briey/tb.sv#L26

A pair of signals per pipeline stage:
* `<STAGE>_pc` - PC of instruction executed by the stage
* `<STAGE>_go` - valid bit when stage is active

```verilog
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

### Dizassembly in WaveQL file

https://github.com/wavedrom/vcd-samples/blob/trunk/examples/Briey/dump.waveql#L17

WaveQL file need to include RegExp that will match `pc` / `go` signal pairs.

```
(DIZ (?<id>\w\w)_((?<go>go)|(?<pc>pc))

)
```

### How to build and simulate

CPU design is from:

https://github.com/SpinalHDL/VexRiscv


Command to build software:

https://github.com/SpinalHDL/VexRiscvSocSoftware/tree/master/projects/murax/demo

fixes:

```diff
diff --git a/resources/gcc.mk b/resources/gcc.mk
index 597f0ba..a9332a2 100644
--- a/resources/gcc.mk
+++ b/resources/gcc.mk
@@ -21,6 +21,7 @@ endif
 ifeq ($(COMPRESSED),yes)
        MARCH := $(MARCH)ac
 endif
+MARCH := $(MARCH)_zicsr

 CFLAGS += -march=$(MARCH)  -mabi=$(MABI)
 LDFLAGS += -march=$(MARCH)  -mabi=$(MABI)
```

```diff
diff --git a/resources/subproject.mk b/resources/subproject.mk
index 3aba0d6..b7458b9 100755
--- a/resources/subproject.mk
+++ b/resources/subproject.mk
@@ -1,15 +1,15 @@

-all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).asm $(OBJDIR)/$(PROJ_NAME).v
+all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).asm $(OBJDIR)/$(PROJ_NAME).lst $(OBJDIR)/$(PROJ_NAME).v

 $(OBJDIR)/%.elf: $(OBJS) | $(OBJDIR)
        $(RISCV_CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)
@@ -49,22 +49,25 @@ $(OBJDIR)/%.elf: $(OBJS) | $(OBJDIR)

 %.bin: %.elf
        $(RISCV_OBJCOPY) -O binary $^ $@

 %.v: %.elf
        $(RISCV_OBJCOPY) -O verilog $^ $@



 %.asm: %.elf
        $(RISCV_OBJDUMP) -S -d $^ > $@

+%.lst: %.elf
+       $(RISCV_OBJDUMP) --source --all-headers --demangle --line-numbers --wide $< > $@
+
 $(OBJDIR)/%.o: %.c
        mkdir -p $(dir $@)
        $(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^

@@ -79,9 +82,7 @@ clean:
        rm -f $(OBJDIR)/$(PROJ_NAME).map
        rm -f $(OBJDIR)/$(PROJ_NAME).v
        rm -f $(OBJDIR)/$(PROJ_NAME).asm
+       rm -f $(OBJDIR)/$(PROJ_NAME).lst
        find $(OBJDIR) -type f -name '*.o' -print0 | xargs -0 -r rm

 .SECONDARY: $(OBJS)

```

Command to build CPU:

```
sbt "runMain vexriscv.demo.BrieyWithMemoryInit"
```

Command to run simulation:

```bash
iverilog -g2005-sv -o sim Briey.v tb.sv && vvp sim +duration=1000 +vcdname=dump1.vcd
```
