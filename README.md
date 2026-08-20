<h1 align="center">figma-to-code-skill</h1>

<h3 align="center">Builds the frame with your tokens — not with its memory of them.</h3>

An agent skill for turning a Figma frame into code **in a project it has never seen**. Before it writes anything it works out where that project keeps its design tokens, component library, routing, and icon set — then it diffs the frame against the code that already exists and stops for approval before touching a file.

The rule underneath all of it: no colour, radius, spacing, or size is ever written from memory. Every value is remapped against a file opened in that session, or the agent stops and asks.

## Install

```sh
npx skills add kanwhile/figma-to-code-skill --skill figma-to-code
```

Add `-g` to install for all projects. Then hand it a Figma link in your own words, or invoke it directly in agents that expose skills as slash commands:

```
/figma-to-code build node 222:105303 into the warehouse flow
```

## The five moves

| Move | What happens |
|---|---|
| **1. Pull** | Fetch the frame (`fileKey` + `nodeId`). No MCP? Work from an exported screenshot — and say so, because a screenshot cannot report Auto Layout gaps. |
| **2. Learn the project** | Read `AGENTS.md`/`CLAUDE.md` first, then discover whatever is missing: token source, component catalog, router, icon set, run and verify commands. State the profile out loud. |
| **3. Diff** | Find the existing screen, compare block by block, and sort every difference into **matches** / **delta** / **new**. |
| **4. Stop** | Report the profile, the three buckets, and the intended token mapping. Wait. No edits before the reply. |
| **5. Build and verify** | Follow the house patterns, cite node ids in comments, then run the static checks, start the app, and do a browser pass beside the frame. |

Move 3 is the one that pays for itself. Frames are usually 80% components that already exist, and a node that is already built means the job is *adjust*, not rebuild.

## The rules it enforces

**Read values, never recall them.** A remembered token is wrong more often than anyone expects — projects change them, and a value that was correct on the day it was copied is still a bug six months later. Two real failure modes taught this: a reference table written from memory with every neutral step off by one, and a correct-at-copy-time table that quietly went stale.

**Generated code is a hint, not source.** Dev Mode output and codegen plugins emit `bg-[#fafafa]` and `rounded-[12px]` because they cannot see your token layer. Read them for intent — hierarchy, rhythm, layout direction — then map every value yourself.

**Stop before building, not after.** The approval gate sits between the diff and the first edit, where changing course is still free.

**Point, don't copy.** The skill ships no token table, no component list, no app map. That knowledge belongs to each project and drifts within weeks of being copied anywhere else — including into a skill.

**Discoveries go in the project's memory.** If working out the profile cost real effort, the skill offers to write six lines into that project's `AGENTS.md`/`CLAUDE.md`. *That file is the cache; the skill is the method.*

**No token match means ask.** Not "pick something close". This is the branch that keeps a design system alive.

## What's in the box

```
skills/figma-to-code/
├── SKILL.md                          the five moves, hard rules, definition of done
├── references/
│   ├── discover-project.md           six questions + recipes for answering them in any stack
│   ├── token-discipline.md           the remap ladder and the traps that break it
│   └── verify.md                     static checks, run it, browser pass, compare
└── scripts/
    └── check-arbitrary-values.sh     flags arbitrary Tailwind and inline hex in changed files
```

`discover-project.md` is what makes the skill portable: token sources (Tailwind v4 `@theme`, v3 config, shadcn `components.json`, plain CSS variables, `theme.ts`, `tokens.json`, native), component catalogs (Storybook, Ladle, Histoire, in-app `/ds` routes), a URL-to-file table covering six routers, icon sets, and the project's own run and verify commands. "This project has no token layer" is treated as a valid answer that ends in a question, not in a silently-invented system.

## Notes

- **Monorepo-aware.** The profile is resolved per app or package. Sibling apps routinely disagree about radius scales, icon sets, and even routers, so a pattern lifted from a sibling is treated as a bug until proven otherwise.
- **Source files beat documentation.** When a pattern doc and the file it describes disagree about a value, the file wins and the drift gets reported.
- **The checker is a backstop, not the procedure.** It cannot catch a value that maps to a real token but the wrong one. It takes a per-repo allowlist in `.figma-to-code-allow` for idioms a project has accepted.
- The skill is in English; the code it writes follows the language of the app it is working in.

## License

MIT
