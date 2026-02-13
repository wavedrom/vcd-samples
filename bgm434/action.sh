#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Install dependencies (only in GitHub Actions)
if [[ -n "$GITHUB_ACTIONS" ]]; then
  sudo apt-get update
  sudo apt-get install -y iverilog brotli
fi

# Run simulation
iverilog -g2005-sv -o sim tb.sv \
  pow_5_pipelined_with_credit_counter.sv \
  pow_5_pipelined_without_flow_control.sv \
  reg_without_flow_control.sv \
  ff_fifo_wrapped_in_valid_ready.sv \
  flip_flop_fifo_with_counter.sv \
  flip_flop_fifo_empty_full_optimized.sv
rm -f dump.vcd
mkfifo dump.vcd
brotli -q 9 < dump.vcd > dump.vcd.br &
vvp sim +duration=100000 +vcdname=dump.vcd

# Wait for brotli to finish
wait

# GitHub Actions: commit and push
if [[ "$GITHUB_EVENT_NAME" == "push" || "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
  git config --local user.email "github-actions[bot]@users.noreply.github.com"
  git config --local user.name "github-actions[bot]"
  git add dump.vcd.br
  if ! git diff --staged --quiet; then
    git commit -m "Update bgm434 VCD from simulation [skip ci]"
    git pull --rebase
    git push
  fi
fi

# GitHub Actions: add summary
if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
  cat >> "$GITHUB_STEP_SUMMARY" <<EOF

✅ Simulation completed successfully!

### View Waveform

[View bgm434 Waveform](https://wavedrom.live/?github=${GITHUB_REPOSITORY}/trunk/bgm434/dump.vcd.br&github=${GITHUB_REPOSITORY}/trunk/bgm434/dump.waveql)

EOF
fi

