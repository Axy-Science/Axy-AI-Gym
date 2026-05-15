# Problem Solving Gym

A competitive problem-solving repo for the dev team. Solve problems, run the eval, push your results, claim your rank on the scoreboard.

## How to participate

1. Clone the repo.
2. Pick a problem from `problems/`.
3. Read `problem.md` in that problem's folder.
4. Create your submission folder: `problems/<problem-slug>/submissions/<your-github-handle>/`
5. Write your solution in any language — the eval just needs a command to run it.
6. Run the eval **from inside the problem folder** (paths are interpreted relative to your current directory). Each problem ships with per-platform `evaluate` binary — `ls` to see which.

   **Binary-eval problems** (e.g. `problem-1`):
   ```
   cd problems/<problem-slug>
   # macOS (Apple Silicon)
   ./evaluate "python3 submissions/<handle>/solution.py" submissions/<handle>/results.md
   # Linux
   ./evaluate-linux-amd64 "python3 submissions/<handle>/solution.py" submissions/<handle>/results.md
   # Windows (PowerShell or cmd)
   .\evaluate.exe "python submissions\<handle>\solution.py" submissions\<handle>\results.md
   ```

   Other languages work the same way — substitute the command (`node solution.js`, `go run solution.go`, etc.).
7. Iterate until you're happy with your score. The eval overwrites `results.md` each run.
8. Commit `results.md` (required) and optionally your `solution.*`, push, and open a PR.

   > **Committing your solution is optional.** The scoreboard only needs `results.md`. If you push your `solution.*`, anyone who pulls `main` or branches off it can read your approach — great for sharing, less ideal if you want to keep things competitive while the problem is still active. To keep your solution private, commit only the results file:
   > ```
   > git add problems/<problem-slug>/submissions/<your-handle>/results.md
   > ```
   > Just make sure your `solution.*` stays in your submission folder locally so the eval can re-run it.
9. Wait for RshmanGit to merge your PR. Once done you score will be visible on the live dashbaord

## Scoreboard

Live scoreboard: https://axy-ai-gym.vercel.app/

Rankings are sorted by score (highest first). Ties are broken by submission time (earliest wins).