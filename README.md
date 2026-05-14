# Problem Solving Gym

A competitive problem-solving repo for the dev team. Solve problems, run the eval, push your results, claim your rank on the scoreboard.

## How to participate

1. Clone the repo.
2. Pick a problem from `problems/`.
3. Read `problem.md` in that problem's folder.
4. Create your submission folder: `problems/<problem-slug>/submissions/<your-github-handle>/`
5. Write your solution in any language — the eval script just needs a command to run it.
6. Run the eval script from inside the problem folder:
   ```
   cd problems/<problem-slug>
   bash evaluate.sh "<command to run your solution>" submissions/<your-handle>/results.md
   ```
   Examples:
   - Python: `bash evaluate.sh "python3 submissions/aarsh/solution.py" submissions/aarsh/results.md`
   - Node:   `bash evaluate.sh "node submissions/aarsh/solution.js" submissions/aarsh/results.md`
7. Iterate until you're happy with your score.
8. Commit your `solution.*` and `results.md`, push, and open a PR.
9. Once merged, the scoreboard updates automatically on next build.

## Scoreboard

Live scoreboard: _(deploy URL — fill in when Vercel is wired up)_

Rankings are sorted by score (highest first). Ties are broken by submission time (earliest wins).

## Adding new problems (for maintainers)

1. Create a new folder under `problems/<slug>/`.
2. Add `problem.md` with required frontmatter:
   ```yaml
   ---
   title: "Your Problem Title"
   slug: "<slug>"             # must match folder name
   published_at: YYYY-MM-DD
   ---
   ```
   followed by the full problem statement.
3. Add test cases in `tests/`: matched pairs `input-N.txt` and `expected-N.txt`.
4. Add `evaluate.sh` following the same interface: takes `<solution_command>` and `<output_path>` arguments and writes a `results.md` with frontmatter:
   ```yaml
   ---
   author: "<handle>"
   total_points: <int>
   score: <int>
   submitted_at: "<ISO 8601 UTC>"
   ---
   ```
5. `chmod +x evaluate.sh`.

## Local development

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # static output in dist/
npm run preview  # serve dist/
```
