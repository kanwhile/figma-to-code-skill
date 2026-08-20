---
name: figma-to-code
description: Turn a Figma frame into code in whatever project you are in — learns that project's own tokens, component library, and routing before writing anything, diffs the frame against code that already exists, and holds every value to a token instead of an arbitrary hex. Use when a task supplies a Figma node, frame, link, or design screenshot, or asks to build, redesign, or check a screen against a design.
---

# Figma → code

<what-to-do>

Five moves, in order. Moves 3 and 4 are not optional.

**1 — Pull the design.**
Fetch the frame through a Figma MCP (`get_design_context` + `get_screenshot`, or the equivalent your host exposes). These need a `fileKey` **and** a `nodeId` — there is no current-selection mode, so ask for the link instead of guessing an id.
No MCP available? Work from an exported screenshot plus the measurements you ask for. Say which you are working from — a screenshot cannot tell you Auto Layout gaps.
**Generated code is a hint about intent, never source.** Dev Mode and codegen plugins emit arbitrary values (`bg-[#fafafa]`, `rounded-[12px]`, inline styles). Those get remapped in move 5, not pasted.

**2 — Learn the project before you touch it.**
Read the project's agent memory first — `AGENTS.md`, `CLAUDE.md`, or whatever it keeps. If the answers are already written down, use them; do not re-derive.
Whatever is missing, discover it with [references/discover-project.md](references/discover-project.md), then **state the profile out loud** before building:

> framework / router · token source · component library + catalog · icon set · run command + port · verify commands

In a monorepo, resolve that profile **per app or package** — siblings routinely disagree about radius scales, icon sets, and even routers.
Then inventory what exists. Most frames are mostly assembly of components already built.

**3 — Diff the frame against the code that exists.**
Locate the current screen first (routing rules in `discover-project.md`), then compare block by block and sort every difference:

- ✅ **matches** — leave it alone
- 🔀 **delta** — built, but differs from the frame
- 🆕 **new** — nothing exists yet

If it is already built, the job is *adjust*, not rebuild. Say so rather than starting over.

**4 — 🛑 Stop and report.**
Post the profile, the three buckets, and the token mapping you intend to use — names, per [references/token-discipline.md](references/token-discipline.md) — then wait. No edits before that reply.

**5 — Build, then verify.**
Follow the house patterns you found in move 2; never hand-roll a page shell the project already owns. Cite the Figma node id in a comment above each non-obvious block, so the next person can re-diff.
Then run the ladder in [references/verify.md](references/verify.md): static checks → run it → browser pass beside the frame.

</what-to-do>

<supporting-info>

## Hard rules

- **Read values, never recall them.** Every hex, radius, spacing, and font size must come from a file you opened in this session. A remembered token is wrong surprisingly often — projects change them. Procedure and traps: [references/token-discipline.md](references/token-discipline.md).
- **Point, don't copy.** This skill carries no token table, no component list, no app map on purpose. That knowledge belongs to each project and drifts within weeks of being copied anywhere else.
- **Discoveries go in the project's memory, not in this skill.** If move 2 cost real effort, offer to write the profile into the project's `AGENTS.md`/`CLAUDE.md` so the next session skips it. That file is the cache; this skill is the method.
- **Ask instead of inventing.** No matching token, no node id, an ambiguous frame, a value that fits no scale — stop and ask. Inventing a plausible value is the most expensive failure mode of this workflow, because it looks right.

## Definition of done

- [ ] Every visual value traces to a token or the framework's own scale; `scripts/check-arbitrary-values.sh` is clean or its remaining hits are justified
- [ ] Existing components reused; any new shared component justified out loud
- [ ] The project's own typecheck / lint / test commands pass
- [ ] Seen running in a browser beside the frame — static checks are not verification
- [ ] Figma node ids left in comments on the non-obvious blocks
- [ ] Deltas you chose *not* to fix are reported, with reasons
- [ ] Anything durable you learned landed in the project's agent memory

</supporting-info>
