#!/bin/bash

# Usage: bash evaluate.sh <solution_command> <output_path>
# Example: bash evaluate.sh "python3 submissions/aarsh/solution.py" submissions/aarsh/results.md

set -e

SOLUTION_CMD="$1"
OUTPUT_PATH="$2"

if [ -z "$SOLUTION_CMD" ] || [ -z "$OUTPUT_PATH" ]; then
  echo "Usage: bash evaluate.sh <solution_command> <output_path>"
  echo "Example: bash evaluate.sh \"python3 submissions/aarsh/solution.py\" submissions/aarsh/results.md"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests"
POINTS_PER_TEST=20
TOTAL_POINTS=100
SCORE=0
DETAILS=""
TEST_COUNT=0

for input_file in "$TESTS_DIR"/input-*.txt; do
  base="${input_file##*/}"          # input-3.txt
  test_num="${base#input-}"         # 3.txt
  test_num="${test_num%.txt}"       # 3
  expected_file="$TESTS_DIR/expected-$test_num.txt"
  TEST_COUNT=$((TEST_COUNT + 1))

  if [ ! -f "$expected_file" ]; then
    DETAILS="$DETAILS\n### Test $test_num — SKIP\nExpected output file missing.\n"
    continue
  fi

  actual=$($SOLUTION_CMD < "$input_file" 2>&1) || true
  expected=$(cat "$expected_file")

  if [ "$actual" = "$expected" ]; then
    SCORE=$((SCORE + POINTS_PER_TEST))
    DETAILS="$DETAILS\n### Test $test_num — PASS (+$POINTS_PER_TEST pts)\n"
  else
    DETAILS="$DETAILS\n### Test $test_num — FAIL\n\n**Expected:**\n\`\`\`\n$expected\n\`\`\`\n\n**Got:**\n\`\`\`\n$actual\n\`\`\`\n"
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
