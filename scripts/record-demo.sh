#!/bin/bash
# Record Output Diffing Utility demo
source "$(dirname "$0")/lib/demo-framework.sh"

TOOL_NAME="output-diffing-utility"
SHORT_NAME="odiff"
LANGUAGE="rust"

# GIF parameters
GIF_COLS=100
GIF_ROWS=30
GIF_SPEED=1.0
GIF_FONT_SIZE=14

demo_setup() {
  # Create sample files for the demo
  echo -e "line 1\nline 2\nline 3" > /tmp/file1.txt
  echo -e "line 1\nline X\nline 3" > /tmp/file2.txt
  echo '{"name":"Alice","age":30}' > /tmp/data1.json
  echo '{"name":"Alice","age":31,"city":"NYC"}' > /tmp/data2.json
}

demo_cleanup() {
  # Clean up sample files
  rm -f /tmp/file1.txt /tmp/file2.txt /tmp/data1.json /tmp/data2.json
}

demo_commands() {
  # ═══════════════════════════════════════════
  # Output Diffing Utility / odiff - Tuulbelt
  # ═══════════════════════════════════════════

  # Step 1: Installation
  echo "# Step 1: Install globally"
  sleep 0.5
  echo "$ cargo install --path ."
  sleep 1

  # Step 2: View help
  echo ""
  echo "# Step 2: View available commands"
  sleep 0.5
  echo "$ odiff --help"
  sleep 0.5
  "$BIN" --help | head -30
  sleep 3

  # Step 3: Basic text diff
  echo ""
  echo "# Step 3: Basic text diff"
  sleep 0.5
  echo "$ odiff /tmp/file1.txt /tmp/file2.txt"
  sleep 0.5
  "$BIN" /tmp/file1.txt /tmp/file2.txt || echo ""
  sleep 3

  # Step 4: JSON semantic diff
  echo ""
  echo "# Step 4: JSON semantic diff (field-level)"
  sleep 0.5
  echo "$ odiff /tmp/data1.json /tmp/data2.json"
  sleep 0.5
  "$BIN" /tmp/data1.json /tmp/data2.json || echo ""
  sleep 3

  # Step 5: JSON output format
  echo ""
  echo "# Step 5: JSON report format"
  sleep 0.5
  echo "$ odiff --format json /tmp/data1.json /tmp/data2.json"
  sleep 0.5
  "$BIN" --format json /tmp/data1.json /tmp/data2.json || echo ""
  sleep 3

  # Step 6: Compact output
  echo ""
  echo "# Step 6: Compact output"
  sleep 0.5
  echo "$ odiff --format compact /tmp/file1.txt /tmp/file2.txt"
  sleep 0.5
  "$BIN" --format compact /tmp/file1.txt /tmp/file2.txt || echo ""
  sleep 2

  # Step 7: Quiet mode (exit code only)
  echo ""
  echo "# Step 7: Quiet mode (exit code only)"
  sleep 0.5
  echo "$ odiff --quiet /tmp/file1.txt /tmp/file2.txt"
  echo "$ echo \"Exit code: \$?\""
  sleep 0.5
  "$BIN" --quiet /tmp/file1.txt /tmp/file2.txt || echo "Exit code: $?"
  sleep 2

  echo ""
  echo "# Done! Compare outputs with: odiff file1 file2"
  sleep 1
}

run_demo
