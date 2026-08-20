import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import ts from "typescript";

// Flags stacked `//` prose comments. The editor wraps for display, so a paragraph belongs on one long `//` line. Commented-out code, pragmas, and list items are exempt. Adapted from colinhacks/zod `scripts/check-comments.ts` (npm + ESLint here; pads and benches ignored).

const IGNORED_PREFIXES = ["packages/bench/", "packages/mobile/"];
const IGNORED_FILES = new Set(["play.ts"]);

const DIRECTIVE =
  /^(?:@ts-|@__|biome-ignore|eslint|prettier-ignore|oxlint|[cv]8 ignore|#(?:region|endregion)|\/|<reference)/;

const LIST_ITEM = /^(?:[-*•+]\s|\d+[.)]\s)/;

const DECLARATION =
  /^(?:import\s+(?:type\s+)?(?:[{*]|\w+\s*[,{]|\w+\s+from\b)|import\s*["']|export\s+(?:default|const|let|var|function|class|interface|type|enum|abstract|declare|async|[*{])|(?:const|let|var)\s+[\w${[][^=]*=|(?:function|class|interface|enum|namespace|module)\s+\w+\s*[<({]|declare\s+\w)/;

function hasCodeStructure(body: string): boolean {
  return (
    /[;{([<]$/.test(body) ||
    /^[)}\]>?:|&.]/.test(body) ||
    /^["'[]/.test(body) ||
    /^[A-Z]\w*\s+extends\s/.test(body) ||
    /^[\w$.[\]]+\s*=[^=]/.test(body) ||
    DECLARATION.test(body)
  );
}

function hasCodeHints(body: string): boolean {
  return (
    /[,:]$/.test(body) ||
    /`/.test(body) ||
    /=>|&&|\|\||\?\?|===|!==|\+\+/.test(body) ||
    /^[\w$.[\]"']+[<(]/.test(body) ||
    /^\w+\s*:\s*[\w$]+[.<([]/.test(body) ||
    /^(?:type|return|throw|await|async|if|else|for|while|do|switch|case|try|catch|finally|new|delete|yield|readonly|static|public|private|protected|abstract|class|interface|function|import|export|const|let|var|enum|namespace|declare)\b/.test(
      body,
    )
  );
}

function looksLikeEnglish(body: string): boolean {
  const words = body.split(/\s+/).filter(Boolean);
  if (words.length < 3) {
    return false;
  }
  const wordy = words.filter((w) => /^[A-Za-z][A-Za-z'-]*[.,;:!?)]?$/.test(w)).length;
  return wordy / words.length >= 0.6;
}

function isProse(body: string): boolean {
  if (hasCodeStructure(body)) {
    return false;
  }
  return looksLikeEnglish(body) || !hasCodeHints(body);
}

interface Block {
  line: number;
  bodies: string[];
}

function ownLineComments(fileName: string, text: string, lines: string[]): Map<number, string> {
  const sf = ts.createSourceFile(fileName, text, ts.ScriptTarget.Latest, false);

  const starts = new Set<number>();
  const collect = (ranges: ts.CommentRange[] | undefined) => {
    for (const range of ranges ?? []) {
      if (range.kind === ts.SyntaxKind.SingleLineCommentTrivia) {
        starts.add(range.pos);
      }
    }
  };
  const visit = (node: ts.Node) => {
    collect(ts.getLeadingCommentRanges(text, node.pos));
    collect(ts.getTrailingCommentRanges(text, node.end));
    node.forEachChild(visit);
  };
  visit(sf);
  collect(ts.getLeadingCommentRanges(text, sf.endOfFileToken.pos));

  const owned = new Map<number, string>();
  for (const pos of starts) {
    const { line, character } = sf.getLineAndCharacterOfPosition(pos);
    if (lines[line].slice(0, character).trim() !== "") {
      continue;
    }
    owned.set(line, lines[line].trim().slice(2).trim());
  }
  return owned;
}

function proseBlocks(fileName: string, text: string, lines: string[]): Block[] {
  const owned = ownLineComments(fileName, text, lines);
  const blocks: Block[] = [];

  for (const line of [...owned.keys()].sort((a, b) => a - b)) {
    const body = owned.get(line);
    if (body === undefined) {
      continue;
    }
    if (body === "" || DIRECTIVE.test(body)) {
      continue;
    }
    const last = blocks.at(-1);
    if (last && last.line + last.bodies.length === line && !LIST_ITEM.test(body)) {
      last.bodies.push(body);
    } else {
      blocks.push({ line, bodies: [body] });
    }
  }

  return blocks.filter((block) => block.bodies.length > 1 && block.bodies.every(isProse));
}

function trackedFiles(): string[] {
  const paths = execFileSync("git", ["ls-files", "-z", "*.ts", "*.mts", "*.cts"], {
    encoding: "utf8",
  }).split("\0");
  return [...new Set(paths)].filter(
    (file) =>
      Boolean(file) &&
      !/\.d\.[cm]?ts$/.test(file) &&
      !IGNORED_FILES.has(file) &&
      !IGNORED_PREFIXES.some((prefix) => file.startsWith(prefix)),
  );
}

const fix = process.argv.includes("--fix");
let violations = 0;
let touched = 0;

for (const file of trackedFiles()) {
  const text = readFileSync(file, "utf8");
  const lines = text.split("\n");
  const blocks = proseBlocks(file, text, lines);
  if (blocks.length === 0) {
    continue;
  }
  violations += blocks.length;

  if (fix) {
    const next: Array<string | null> = [...lines];
    for (const block of blocks) {
      const indent = /^[ \t]*/.exec(lines[block.line])?.[0] ?? "";
      next[block.line] = `${indent}// ${block.bodies.join(" ")}`;
      for (let i = 1; i < block.bodies.length; i++) {
        next[block.line + i] = null;
      }
    }
    writeFileSync(file, next.filter((line): line is string => line !== null).join("\n"));
    touched += 1;
    continue;
  }

  for (const block of blocks) {
    console.error(`${file}:${block.line + 1}: ${block.bodies.length} stacked comment lines`);
    for (const body of block.bodies) {
      console.error(`  // ${body}`);
    }
  }
}

if (violations === 0) {
  console.log("No stacked comment lines");
} else if (fix) {
  console.log(`Joined ${violations} stacked comment block(s) across ${touched} file(s)`);
} else {
  console.error(
    `\n${violations} stacked comment block(s). Join each into one line, or run \`npm run check:comments -- --fix\`.`,
  );
  process.exit(1);
}
