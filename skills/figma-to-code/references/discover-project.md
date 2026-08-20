# Discovering a project's design surface

Six questions. Answer them **before** move 3, state the answers in move 4, and never assume the answer from a
project you worked on last week. The recipes below are starting points — stop as soon as you have a real answer.

Run them from the app root. In a monorepo, answer **per app or package**: siblings routinely disagree about
radius scales, icon sets, and even routers.

## 0. Is it already written down?

```bash
ls AGENTS.md CLAUDE.md .cursorrules .github/copilot-instructions.md 2>/dev/null
find . -maxdepth 3 -name "AGENTS.md" -not -path "*/node_modules/*" 2>/dev/null
```

Read these first. A project that keeps agent memory usually documents its conventions, its sharp edges, and which
files are generated. Trust it over your own inference — but if it contradicts a source file, **the source file wins**
and the doc is a bug worth reporting.

Also worth a look: `README`, `CONTRIBUTING.md`, `docs/`, and any `design/`, `DS-*.md`, or `*-PATTERNS.md` file.

## 1. Where do design tokens live?

Try in order; the first hit that the app entry actually imports is the answer.

```bash
# Tailwind v4 — tokens are CSS, in an @theme block
grep -rl "@theme" --include="*.css" . --exclude-dir=node_modules 2>/dev/null

# Tailwind v3 — tokens are config
find . -maxdepth 2 -name "tailwind.config.*" -not -path "*/node_modules/*" 2>/dev/null

# shadcn/ui — components.json names the css file that holds the CSS variables
cat components.json 2>/dev/null

# plain CSS variables  (-e, not --, or grep swallows the --include flags)
grep -rnE -e "^[[:space:]]*--[a-z0-9-]+[[:space:]]*:" --include="*.css" --include="*.scss" --exclude-dir=node_modules . 2>/dev/null | head

# CSS-in-JS / native
find . -maxdepth 4 \( -name "theme.ts" -o -name "theme.tsx" -o -name "tokens.json" -o -name "*.tokens.json" \
  -o -name "_variables.scss" -o -name "Colors.swift" -o -name "theme.dart" \) -not -path "*/node_modules/*" 2>/dev/null
```

**No token layer at all** (plain CSS, inline styles, a hand-rolled stylesheet) is a real answer — say so, and ask
whether to follow the existing style or introduce tokens. Do not silently start a token system.

Two-tier setups are common: a shared package holds brand primitives, each app owns its semantic palette. Find both
before mapping anything.

## 2. What component library, and is there a catalog?

```bash
# a rendered catalog is the fastest inventory that exists — run it
ls .storybook .ladle .histoire 2>/dev/null
grep -rn "storybook\|ladle\|histoire" package.json 2>/dev/null

# in-app catalogs hide behind routes like /ds, /design-system, /styleguide, /ui
find . -maxdepth 5 -type d \( -name "ds" -o -name "design-system" -o -name "styleguide" \) \
  -not -path "*/node_modules/*" 2>/dev/null

# the usual homes for shared components
find . -maxdepth 4 -type d \( -path "*/components/ui" -o -name "ui" -o -name "design-system" \) \
  -not -path "*/node_modules/*" 2>/dev/null | head
```

Note the layering convention too (primitives → composites → feature blocks → layouts, or whatever this project uses).
Building at the wrong layer is the most common review comment on this kind of work.

## 3. How do I get from a URL to the file that renders it?

Identify the router, then it is a lookup rather than a search:

| clue | routing |
|---|---|
| `app/**/page.tsx` | Next.js App Router — URL = directory path, `[param]` dynamic |
| `pages/**/*.tsx` | Next.js Pages Router / Nuxt — URL = file path |
| `src/routes/` + `routeTree.gen.ts` | TanStack Router file-based — URL = file path; pathless layouts are `_prefix` dirs |
| `src/routes/` + `+page.svelte` | SvelteKit |
| `createBrowserRouter` / `<Route>` | React Router config — grep the path string |
| `router/index.ts` with a `routes:` array | Vue Router |

Generated route manifests (`routeTree.gen.ts`, `.next/types`) settle ambiguity — grep them, do not read them whole,
and never hand-edit them.

Last resort: grep a unique visible string from the screen (a Thai label, a button caption).

## 4. Which icon set?

```bash
node -e "const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};console.log(Object.keys(d).filter(k=>/icon|lucide|heroicons|phosphor|feather|remix/i.test(k)).join(', ')||'none')"
```

Mixed sets in one repo are normal and are usually **per package, not per repo** — a shared UI package may use a
different set than the app that consumes it. Match the file you are editing, not the repo's headline rule.
Note the variant too: stroke vs solid vs duotone are separate packages, and a frame that draws an active tab filled
needs the filled package installed.

## 5. How do I run it, and how do I check it?

```bash
node -e "const p=require('./package.json');console.log(p.name); console.log(p.scripts)"
```

Look for `dev`, `build`, `typecheck`, `lint`, `test`, `e2e`, `storybook`. The dev port is usually a flag in the
`dev` script, otherwise in `vite.config.*` / `next.config.*`.
Monorepo? Find the runner — `pnpm --filter <pkg> <script>`, `turbo run`, `nx run`, `yarn workspace`. Running the
script from the app directory usually works too, but the repo's own invocation is what CI uses.

**Two apps that claim the same port is a real hazard** — check what is already listening before believing a screenshot.

## Then write it down

If answering these cost real work, offer to add a short profile to the project's `AGENTS.md` / `CLAUDE.md` — six
lines, pointing at files rather than restating their contents:

```markdown
## Design surface
- tokens: `src/index.css` (`@theme`) + `packages/ui/src/styles.css` (brand primitives only)
- components: `src/components/{ui,composite,feature,layout}`; live catalog at `/ds`
- routing: TanStack file-based under `src/routes/`; `_private` is a pathless layout
- icons: hugeicons (stroke); `packages/ui` uses lucide — match the package you edit
- run: `pnpm --filter @app/web dev` → :3002 · check: `typecheck`, `lint`, `e2e`
- patterns doc: `design/UI-PATTERNS.md` (source files win where it disagrees)
```

That file is the cache. This skill is the method. Never move the answers into the skill.
