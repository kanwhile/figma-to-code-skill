# Token discipline

Design tools export **values**. Codebases are built on **names**. The whole job of this step is the translation, and
the only trustworthy input is a file you opened in this session.

## Why this is a rule and not a preference

Two failure modes, both observed in real work:

- **Invented authority.** A reference table written from memory — every neutral step off by one, a status colour
  invented outright. It read as authoritative, so nobody re-checked it, and every screen built from it was wrong in
  the same direction.
- **Copied-then-stale.** A table that was *correct* on the day it was copied. The project changed the value months
  later; the copy kept being quoted. Correct-at-copy-time is not a defence — the copy itself was the bug.

So: no value gets written from memory, and no value gets cached anywhere outside its source of truth.

## The remap ladder

For every colour, radius, spacing, font size, and shadow in the frame:

1. **Semantic token** — the project's own name for that role (`primary`, `muted-foreground`, `success-soft`,
   `surface-raised`). Search the token source you found in `discover-project.md`.
2. **Primitive token** — a raw scale entry the project defines (`neutral-50`, `blue-600`, `space-4`).
3. **Framework's own scale** — many "arbitrary-looking" values are stock. `#FAFAFA` is Tailwind's `neutral-50`;
   `0.5rem` is `2` on the default spacing scale. **Confirm by grepping the class in the codebase** — if the project
   already uses it, you have your answer.
4. **Nothing matches → stop and ask.** Do not introduce an arbitrary value to keep moving. This is the branch that
   protects the design system; taking it silently is how a token system dies.

Report the **name** in move 4 — `bg-neutral-50`, `rounded-sm`, `text-muted-foreground` — never the raw value. The
value lives in the token file; repeating it in a report, a comment, or a doc creates the copy that goes stale.

## Traps, in the order they bite

**Scales get overridden.** A project can pin one step off its own `calc()` chain to match a frame, or replace the
whole type scale to match a native app's design system. Mapping "12px → the `xl` step" from habit is wrong whenever
that happened. Read the scale definition every time.

**Monorepos disagree with themselves.** Radius, icon set, and even the router can differ between sibling apps, and a
shared UI package often follows different rules than the apps consuming it. A pattern lifted from a sibling is a bug
until proven otherwise.

**Prose about tokens goes stale faster than tokens.** Pattern docs, style guides, and token pages that mirror values
by hand drift from the file that defines them. **The source file wins over every doc — including this one.** When you
spot a drift, report it in move 4 instead of quietly following the doc.

**Theme modes double every answer.** If the project has light/dark (or brand themes), a colour is a *pair*. Check
which block you are reading before mapping, and check the frame actually specifies which mode it is.

**Generated code is not a source.** Dev Mode output, codegen plugins, and AI-written snippets all emit arbitrary
values because they cannot see your token layer. Read them for intent — spacing rhythm, hierarchy, Auto Layout
direction — then map every value yourself.

**Effects and type are usually under-tokenized.** Shadows, blurs, letter-spacing, and line-heights often have no
token even in a mature system. That is exactly the case for step 4: ask, do not invent a new scale mid-task.

## Backstop

`scripts/check-arbitrary-values.sh` greps changed files for arbitrary Tailwind values and raw hex. It is a net under
the procedure, not the procedure: it cannot catch a value that maps to a real token but the **wrong** one.
