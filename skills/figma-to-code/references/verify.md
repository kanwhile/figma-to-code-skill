# Verify

A screen is verified when it has been **seen running, beside the frame**. Everything before that is a smoke test.

## 1. Static checks

Use the project's own scripts — the ones CI runs, found in move 2:

```bash
<runner> typecheck      # or: tsc --noEmit
<runner> lint
<runner> test
scripts/check-arbitrary-values.sh
```

Never hand-edit generated files (route manifests, generated types, lockfiles) to make a check pass. Fix the source
they are generated from and regenerate.

## 2. Run it

Start the dev server the project's way, on the port you found in move 2. If two apps in the repo claim the same
port, confirm what is actually listening before trusting anything you see.

Behind a login wall? Look for the project's own test recipe — Playwright/Cypress fixtures, a seed script, a dev-only
bypass — before hand-rolling credentials. Grep the e2e directory first.

## 3. Browser pass

Use whatever the host gives you (a Chrome DevTools MCP, Playwright, or the user's own browser). Two rules that
survive every toolchain:

- **Isolate your session** when the browser bridge is shared machine-wide. A sibling task's navigation landing in
  your tab produces redirects with no explanation in the app code, and it will cost you an hour.
- **Prefer in-app navigation over hard page loads** once past first paint. Mock stores and in-memory state live in
  page JS and a full load wipes them.

Two assertion traps: clicking the centre of a wrapped text node can hit an inline neighbour a line below, and
mutating then reading React state in one `eval` returns the pre-render value — split it into two calls.

## 4. Compare against the frame

Put the screenshot beside the running screen and check in this order — the earlier items make the later ones move:

1. page shell, safe areas, max width
2. block order and spacing rhythm
3. corner radii and borders
4. type sizes, weights, line heights
5. colour roles (not hexes — roles: is that *primary* or *destructive*?)
6. icon set and variant (stroke vs filled)
7. states the frame documents — hover, pressed, empty, loading, error, disabled
8. the breakpoints the project actually supports

A quick accessibility pass earns its keep here: visible focus, text contrast, tap targets ≥ 44px on touch surfaces.
Designs routinely omit these, and adding them later is a rewrite.

If the project has visual regression or screenshot capture, extend it rather than duplicating it.

## 5. Close the loop

- Report deltas you **chose not to fix**, with reasons. A silent omission reads as "matches the frame" to the next
  person, and that misreading is expensive.
- Say what you could not verify (a state you could not reach, a breakpoint you could not test).
- Put anything durable you learned — a sharp edge, a convention, a generated file, a design section that governs a
  flow — into the project's agent memory, next to the thing it concerns. Not into this skill.
