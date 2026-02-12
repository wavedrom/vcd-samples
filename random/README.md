Random number generator

```bash
iverilog -g2005-sv -o sim counter.v tb.sv && vvp sim +duration=1000000 +vcdname=dump1.vcd
```

https://vc.drom.io/?github=wavedrom/vcd-samples/trunk/random/random.vcd&github=wavedrom/vcd-samples/trunk/random/random.waveql
