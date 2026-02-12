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
iverilog -g2005-sv -o sim Briey.v tb.sv
rm -f dump1.vcd
mkfifo dump1.vcd
brotli -q 9 < dump1.vcd > dump1.vcd.br &
vvp sim +duration=100000 +vcdname=dump1.vcd

# Wait for brotli to finish
wait

# GitHub Actions: commit and push
if [[ "$GITHUB_EVENT_NAME" == "push" || "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
  git config --local user.email "github-actions[bot]@users.noreply.github.com"
  git config --local user.name "github-actions[bot]"
  git add dump1.vcd.br
  if ! git diff --staged --quiet; then
    git commit -m "Update Briey VCD from simulation [skip ci]"
    git pull --rebase
    git push
  fi
fi

# GitHub Actions: add summary
if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
  cat >> "$GITHUB_STEP_SUMMARY" <<EOF
## Briey Pipeline Simulation Results

✅ Simulation completed successfully!

### View Waveform

[View Briey Pipeline](https://wavedrom.live/?github=${GITHUB_REPOSITORY}/trunk/examples/Briey/dump1.vcd.br&github=${GITHUB_REPOSITORY}/trunk/examples/Briey/dump.waveql&github=${GITHUB_REPOSITORY}/trunk/examples/Briey/demo.lst)

EOF
fi

