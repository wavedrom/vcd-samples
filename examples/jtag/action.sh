#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Install Icarus Verilog
sudo apt-get update
sudo apt-get install -y iverilog

# Run simulation
iverilog -o sim jtag.v tb.v
vvp sim

# Commit VCD file (only on push or workflow_dispatch)
if [[ "$GITHUB_EVENT_NAME" == "push" || "$GITHUB_EVENT_NAME" == "workflow_dispatch" ]]; then
  git config --local user.email "github-actions[bot]@users.noreply.github.com"
  git config --local user.name "github-actions[bot]"
  git add jtag.vcd
  if ! git diff --staged --quiet; then
    git commit -m "Update JTAG VCD from simulation [skip ci]"
    git pull --rebase
    git push
  fi
fi

# Add summary
if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
  cat >> "$GITHUB_STEP_SUMMARY" <<EOF
## JTAG Simulation Results

✅ Simulation completed successfully!

### Raw VCD URL
\`\`\`
https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/examples/jtag/jtag.vcd
\`\`\`

### View Waveform
[View JTAG Waveform](https://wavedrom.live/?github=${GITHUB_REPOSITORY}/trunk/examples/jtag/jtag.vcd&github=${GITHUB_REPOSITORY}/trunk/examples/jtag/jtag.waveql)
EOF
fi

