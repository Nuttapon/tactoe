# Mobile Player Mini Card — Design Doc

**Date:** 2026-02-21
**Scope:** Mobile UI improvement (≤560px) — replace empty `.side-head` with a useful player info card

---

## Problem

On mobile, `game-area` switches to `flex-direction:column`. Each `.side` becomes a horizontal flex row. The `.side-head` (showing "— O —" / "— X —") takes up ~50% width next to the ability card while providing minimal value — it's essentially wasted space.

---

## Solution: Approach A — Mini Player Card

Replace `.side-head` with a `.player-mini-card` on mobile that shows:
- Player symbol (O / X) with accent color
- Player name / role label (YOU / BOT / OPPONENT)
- Current score (prominent)
- Turn indicator (glows when active, shows ❄️ when frozen)

### Visual Layout (mobile, ≤560px)

```
┌─────────────────────────────────────────┐
│  O              ║  💣 Bomb              │
│  PLAYER O       ║  Destroy a cell…      │
│  ─────          ║                       │
│  2 pts          ║  [Use Ability]        │
│  ● YOUR TURN    ║                       │
└─────────────────────────────────────────┘
```

- **Active turn:** border glow + animated dot (cyan for O, red for X)
- **Inactive:** dimmed (opacity ~0.4)
- **Frozen:** ❄️ FROZEN replaces turn indicator
- **Bot mode:** "BOT" badge on X side
- **Online mode:** "YOU" / "OPPONENT" labels

### Desktop (>560px)

No change — existing `.side-head` layout remains intact.

---

## Implementation

### HTML
Add `.player-mini-card` inside `#side-o` and `#side-x`, directly before `.ab-card`.

### CSS
- `.player-mini-card`: styled card (same border-radius/panel as `.ab-card`), hidden by default
- `@media(max-width:560px)`: show `.player-mini-card`, hide `.side-head`
- Active state: border glow matching player color (reuse existing `--o` / `--x` variables)
- Turn dot: small pulsing circle (reuse or extend `@keyframes` already in codebase)

### JS
Add `updateMiniCards()` function:
- Updates score display
- Toggles active/inactive state
- Handles frozen state
- Reflects bot/online labels
- Called inside `renderStatus()` and score update paths

---

## Edge Cases

| Case | Behavior |
|------|----------|
| Bot mode (X = bot) | Shows "BOT" badge |
| Online mode | Shows "YOU" / "OPPONENT" |
| Frozen player | Shows ❄️ FROZEN instead of turn dot |
| Ability used | ab-card dims to 24% opacity (existing `.used` class, unchanged) |
| Board overlay visible | Mini card has no interaction with overlay |
