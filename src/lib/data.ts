import fg from 'fast-glob';
import matter from 'gray-matter';
import fs from 'node:fs';
import path from 'node:path';

const PROJECT_ROOT = process.cwd();
const PROBLEMS_DIR = path.join(PROJECT_ROOT, 'problems');

export interface Problem {
  title: string;
  slug: string;
  published_at: string;
}

export interface ScoreboardEntry {
  rank: number;
  author: string;
  score: number;
  total_points: number;
  submitted_at: string;
}

export interface ProblemWithScoreboard extends Problem {
  problemBody: string;
  scoreboard: ScoreboardEntry[];
}

function toISODate(value: unknown): string {
  if (value instanceof Date) return value.toISOString().slice(0, 10);
  return String(value);
}

export async function getAllProblems(): Promise<Problem[]> {
  const files = await fg('problems/*/problem.md', { cwd: PROJECT_ROOT, absolute: true });
  const problems: Problem[] = files.map((file) => {
    const raw = fs.readFileSync(file, 'utf8');
    const { data } = matter(raw);
    return {
      title: String(data.title),
      slug: String(data.slug),
      published_at: toISODate(data.published_at),
    };
  });
  problems.sort((a, b) => (a.published_at < b.published_at ? 1 : -1));
  return problems;
}

export async function getProblemWithScoreboard(slug: string): Promise<ProblemWithScoreboard> {
  const problemPath = path.join(PROBLEMS_DIR, slug, 'problem.md');
  const raw = fs.readFileSync(problemPath, 'utf8');
  const { data, content } = matter(raw);

  const resultFiles = await fg(`problems/${slug}/submissions/*/results.md`, {
    cwd: PROJECT_ROOT,
    absolute: true,
  });

  const entries = resultFiles.map((file) => {
    const r = matter(fs.readFileSync(file, 'utf8'));
    return {
      author: String(r.data.author),
      score: Number(r.data.score),
      total_points: Number(r.data.total_points),
      submitted_at: String(r.data.submitted_at),
    };
  });

  entries.sort((a, b) => {
    if (b.score !== a.score) return b.score - a.score;
    return a.submitted_at < b.submitted_at ? -1 : a.submitted_at > b.submitted_at ? 1 : 0;
  });

  const scoreboard: ScoreboardEntry[] = [];
  let lastRank = 0;
  let lastKey = '';
  entries.forEach((e, i) => {
    const key = `${e.score}|${e.submitted_at}`;
    const rank = key === lastKey ? lastRank : i + 1;
    lastRank = rank;
    lastKey = key;
    scoreboard.push({ rank, ...e });
  });

  return {
    title: String(data.title),
    slug: String(data.slug),
    published_at: toISODate(data.published_at),
    problemBody: content,
    scoreboard,
  };
}
