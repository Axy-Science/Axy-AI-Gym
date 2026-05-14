#!/bin/bash
# Usage: bash evaluate.sh <solution_command> <output_path>
set -e

SOLUTION_CMD="$1"
OUTPUT_PATH="$2"

if [ -z "$SOLUTION_CMD" ] || [ -z "$OUTPUT_PATH" ]; then
  echo "Usage: bash evaluate.sh <solution_command> <output_path>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests"
TOTAL_POINTS=100
POINTS=(33 33 34)  # index 0..2 -> test 1..3
SCORE=0
DETAILS=""

for i in 1 2 3; do
  input_file="$TESTS_DIR/input-$i.txt"
  expected_file="$TESTS_DIR/expected-$i.txt"
  pts=${POINTS[$((i-1))]}

  if [ ! -f "$input_file" ] || [ ! -f "$expected_file" ]; then
    DETAILS="$DETAILS\n### Test $i — SKIP\nFile missing.\n"
    continue
  fi

  actual=$($SOLUTION_CMD < "$input_file" 2>&1) || true
  expected=$(cat "$expected_file")

  if [ "$actual" = "$expected" ]; then
    SCORE=$((SCORE + pts))
    DETAILS="$DETAILS\n### Test $i — PASS (+$pts pts)\n"
  else
    DETAILS="$DETAILS\n### Test $i — FAIL\n\n**Expected:**\n\`\`\`\n$expected\n\`\`\`\n\n**Got:**\n\`\`\`\n$actual\n\`\`\`\n"
  fi
done

AUTHOR=$(echo "$OUTPUT_PATH" | rev | cut -d'/' -f2 | rev)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$OUTPUT_PATH" << EOF
---
author: "$AUTHOR"
total_points: $TOTAL_POINTS
score: $SCORE
submitted_at: "$TIMESTAMP"
---

# Results — $AUTHOR

**Score: $SCORE / $TOTAL_POINTS**
**Submitted: $TIMESTAMP**

## Test Case Breakdown
$(echo -e "$DETAILS")
EOF

echo ""
echo "============================="
echo "  Score: $SCORE / $TOTAL_POINTS"
echo "  Results written to: $OUTPUT_PATH"
echo "============================="
