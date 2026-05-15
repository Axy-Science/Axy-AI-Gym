# Maintainer Guide — Adding Problems

All new problems **must** use the Go binary + HMAC integrity evaluator. Bash-style evaluators are not accepted for new problems — they leave `results.md` trivially editable and can't be validated by CI. `problem-2` predates this rule and remains as legacy; do not use it as a template for new work.

---

## Problem folder structure

```
problems/<slug>/
├── problem.md              # spec (required)
├── submissions/.gitkeep    # required so the empty folder is tracked
├── evaluate                # macOS arm64 binary
├── evaluate-linux-amd64    # Linux binary
└── evaluate.exe            # Windows binary
```

`problem.md` must start with:

```yaml
---
title: "Human-readable Title"
slug: "<must match folder name>"
published_at: YYYY-MM-DD
---
```

Test inputs and expected outputs are **embedded into the Go binary** (via `//go:embed` or string literals), not shipped as loose files. This is what lets the binary produce a tamper-evident `results.md` and what makes HMAC integrity meaningful.

---

## Go binary + HMAC integrity

Source lives under `_eval-src/` (gitignored, **never committed**). Only compiled binaries land in `problems/<slug>/` and `tools/`.

### Why integrity?

Without it, a participant can hand-edit `results.md` to inflate their score. The HMAC checksum binds `(author, total_points, score, submitted_at)` to the secret key compiled into the binary — any edit invalidates the checksum, and the CI workflow (`.github/workflows/pr-checks.yml`) rejects the PR.

This is *casual-cheating* protection. Someone determined could run `strings` on the binary to recover the secret. That's fine: this is an internal-fun gym, not a prod-grade competition platform.

### Local source layout

```
_eval-src/                  # GITIGNORED
├── go.mod
├── shared/integrity.go     # HMAC + 32-byte hex secret
├── evaluator/main.go       # one per problem (or templated)
├── verifier/main.go        # shared CI verifier
└── *_solution.py           # reference/sample solutions for testing — never committed
```

### Evaluator contract

The binary must take `<solution_cmd> <output_path>` and:
1. Extract `<author>` from the output path (parent of `results.md` under `submissions/`).
2. Run the solution against each embedded test case, with per-test timeouts.
3. Compute the score.
4. Compute `checksum = shared.ComputeChecksum(author, total_points, score, submitted_at)`.
5. Write `results.md` with frontmatter:

```yaml
---
author: "<handle>"
total_points: <int>
score: <int>
submitted_at: "<ISO 8601 UTC>"
checksum: "<hex>"
---
```

### Timeout calibration

For efficiency-tier tests:

1. Write a reference solution in Python using the optimal algorithm.
2. Time it against each large input on your machine.
3. Set the timeout to **5× the measured time** (not 3× — the calibration box is usually faster than a participant's laptop), with a 2-second floor.
4. Document the calibration as a comment in the evaluator source. See `_eval-src/evaluator/main.go` (problem-1) for the template.

### Cross-compile

From `_eval-src/`:

```bash
GOOS=darwin  GOARCH=arm64 go build -o ../problems/<slug>/evaluate              ./evaluator/
GOOS=linux   GOARCH=amd64 go build -o ../problems/<slug>/evaluate-linux-amd64 ./evaluator/
GOOS=windows GOARCH=amd64 go build -o ../problems/<slug>/evaluate.exe         ./evaluator/
chmod +x ../problems/<slug>/evaluate ../problems/<slug>/evaluate-linux-amd64
```

Verifier binaries are shared across all problems and live in `tools/`:

```bash
GOOS=darwin  GOARCH=arm64 go build -o ../tools/verify               ./verifier/
GOOS=linux   GOARCH=amd64 go build -o ../tools/verify-linux-amd64  ./verifier/
GOOS=windows GOARCH=amd64 go build -o ../tools/verify.exe          ./verifier/
chmod +x ../tools/verify ../tools/verify-linux-amd64
```

Commit only binaries. Never commit `.go` source. `_eval-src/` is gitignored for this reason.

### CI scope

`.github/workflows/pr-checks.yml` runs the verifier against `results.md` files under integrity-protected problem paths. **When you add a new problem, update the workflow's `grep` filter to include its path.** Without this, CI will silently not validate submissions for the new problem and participants can hand-edit `results.md` undetected.

---

## Testing checklist before publishing a new problem

1. Run the eval against a known-correct reference solution — confirm full score.
2. Run against a known-incorrect solution — confirm partial/zero score.
3. Run `tools/verify` on the generated `results.md` — confirm `OK`.
4. Edit `score` by 1 in the file, re-verify — confirm `FAIL`. Restore.
5. **Update `.github/workflows/pr-checks.yml`** — extend the `grep -E '^problems/...'` filter to include your new slug.
6. `npm run build` — confirm the new problem appears on the homepage and its page renders cleanly with the empty scoreboard.
7. `git status` — confirm no `.go` source files, no `_eval-src/`, no sample submissions are staged. Only `problem.md`, the three platform binaries, and `submissions/.gitkeep` should be added.
8. **Do not commit reference or sample submissions.** Participants must solve the problem cold.

---

## The HMAC secret

It lives in `_eval-src/shared/integrity.go`. If you regenerate it (`openssl rand -hex 32`), every existing `results.md` checksum becomes invalid — so don't rotate it casually. If you ever do rotate, rebuild every evaluator + verifier binary in the same commit, and either invalidate or re-generate every existing submission's `results.md`.
