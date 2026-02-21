# Mobile Player Mini Card Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the empty "— O —" / "— X —" side-head on mobile (≤560px) with a mini player card showing name, score, and turn indicator.

**Architecture:** Add `.player-mini-card` HTML elements alongside existing `.side-head`, hide side-head on mobile and show mini card instead. Sync card state through a new `updateMiniCards()` function called from existing update hooks (`updSc`, `updScFull`, `setMode`).

**Tech Stack:** Vanilla HTML/CSS/JS, single-file app (`index.html`), no build step.

---

## Key Files & Locations

- **All changes in:** `/Users/nuttapon/Nutty/tactoe/index.html`
- **CSS block:** lines ~10–549 (the `<style>` tag)
- **HTML sidebar O:** line ~614–623 (`#side-o`)
- **HTML sidebar X:** line ~638–647 (`#side-x`)
- **`updSc()` function:** line ~1776
- **`updScFull()` function:** line ~1781
- **`setMode()` function:** line ~1897 (sets `lbl-o`, `lbl-x`, `sh-o`, `sh-x`)
- **Online label section:** line ~2904 (sets `lbl-o`, `lbl-x` for online mode)
- **`render()` / `renderAbs()`:** line ~1331 / ~1789

---

## Task 1: Add `.player-mini-card` CSS

**Files:**
- Modify: `index.html` — inside `<style>`, just before the `@media(max-width:720px)` block (line ~414)

**Step 1: Locate the insertion point**

Find this comment in the CSS (around line 413):
```css
@media(max-width:720px){
```

**Step 2: Insert the new CSS block before that line**

Add the following block:

```css
/* ══ Player Mini Card (mobile sidebar) ════════════════════ */
.player-mini-card{
  display:none; /* hidden on desktop, shown on mobile via media query */
  flex-direction:column; align-items:center; justify-content:center;
  background:var(--panel); border:1px solid var(--dim); border-radius:12px;
  padding:12px 10px; text-align:center; transition:all .3s; position:relative;
  overflow:hidden; gap:4px;
}
.player-mini-card::before{
  content:''; position:absolute; top:0; left:0; right:0; height:3px;
  opacity:0; transition:opacity .3s;
}
.player-mini-card.o::before{ background:var(--o); }
.player-mini-card.x::before{ background:var(--x); }
.player-mini-card.active::before{ opacity:1; }
.player-mini-card.active.o{ box-shadow:0 0 22px rgba(0,255,204,.18); border-color:rgba(0,255,204,.25); }
.player-mini-card.active.x{ box-shadow:0 0 22px rgba(255,51,85,.18); border-color:rgba(255,51,85,.25); }

.pmc-sym{
  font-family:var(--font); font-size:1.8rem; font-weight:700; line-height:1;
}
.player-mini-card.o .pmc-sym{ color:var(--o); text-shadow:0 0 14px rgba(0,255,204,.5); }
.player-mini-card.x .pmc-sym{ color:var(--x); text-shadow:0 0 14px rgba(255,51,85,.5); }

.pmc-name{
  font-family:var(--font); font-size:.68rem; font-weight:700;
  letter-spacing:.12em; text-transform:uppercase; color:#c8d8e8; line-height:1.2;
}
.pmc-score{
  font-family:var(--font); font-size:2rem; font-weight:700; line-height:1; margin:2px 0;
}
.player-mini-card.o .pmc-score{ color:var(--o); }
.player-mini-card.x .pmc-score{ color:var(--x); }
.pmc-score-lbl{
  font-size:.52rem; letter-spacing:.2em; text-transform:uppercase; color:#5a7a90;
}

/* Turn indicator */
.pmc-turn{
  display:flex; align-items:center; gap:5px; margin-top:4px;
  font-family:var(--font); font-size:.58rem; font-weight:700;
  letter-spacing:.1em; text-transform:uppercase; opacity:0; transition:opacity .25s;
}
.pmc-turn.visible{ opacity:1; }
.pmc-dot{
  width:6px; height:6px; border-radius:50%; flex-shrink:0;
}
.player-mini-card.o .pmc-dot{ background:var(--o); animation:pmc-pulse-o 1.1s ease infinite; }
.player-mini-card.x .pmc-dot{ background:var(--x); animation:pmc-pulse-x 1.1s ease infinite; }
@keyframes pmc-pulse-o{
  0%,100%{box-shadow:0 0 0 0 rgba(0,255,204,.6)}
  50%{box-shadow:0 0 0 4px rgba(0,255,204,0)}
}
@keyframes pmc-pulse-x{
  0%,100%{box-shadow:0 0 0 0 rgba(255,51,85,.6)}
  50%{box-shadow:0 0 0 4px rgba(255,51,85,0)}
}
.pmc-frozen{
  font-family:var(--font); font-size:.58rem; font-weight:700;
  letter-spacing:.08em; text-transform:uppercase;
  color:var(--freeze); margin-top:4px; display:none;
}
.pmc-frozen.visible{ display:block; }

/* Light mode overrides */
body.light .player-mini-card{ background:var(--panel); border-color:rgba(0,0,0,.1); }
body.light .pmc-name{ color:#2a3a50; }
body.light .pmc-score-lbl{ color:#7a8fa0; }
```

**Step 3: Update existing mobile media queries to show/hide correctly**

Find the `@media(max-width:560px)` block (around line 421) and add two lines inside it:

```css
@media(max-width:560px){
  /* ... existing rules ... */
  .side-head{ display:none; }          /* ADD: hide text-only header */
  .player-mini-card{ display:flex; }   /* ADD: show rich mini card */
}
```

**Step 4: Verify visually — no commit yet**

Open `index.html` in browser, resize to <560px. The mini cards won't render content yet (JS not wired), but you should see no layout breakage.

---

## Task 2: Add HTML elements

**Files:**
- Modify: `index.html` — HTML section, `#side-o` and `#side-x` divs

**Step 1: Add mini card to `#side-o`**

Find this block (around line 614):
```html
    <div class="side" id="side-o">
      <div class="side-head o" id="sh-o">— O —</div>
      <div class="ab-card" id="ac-o">
```

Add `.player-mini-card` between `side-head` and `ab-card`:
```html
    <div class="side" id="side-o">
      <div class="side-head o" id="sh-o">— O —</div>
      <div class="player-mini-card o" id="pmc-o">
        <div class="pmc-sym">O</div>
        <div class="pmc-name" id="pmc-name-o">Player O</div>
        <div class="pmc-score" id="pmc-score-o">0</div>
        <div class="pmc-score-lbl">pts</div>
        <div class="pmc-turn" id="pmc-turn-o">
          <span class="pmc-dot"></span>
          <span id="pmc-turn-txt-o">YOUR TURN</span>
        </div>
        <div class="pmc-frozen" id="pmc-frozen-o">❄️ FROZEN</div>
      </div>
      <div class="ab-card" id="ac-o">
```

**Step 2: Add mini card to `#side-x`**

Find this block (around line 638):
```html
    <div class="side" id="side-x">
      <div class="side-head x" id="sh-x">— X —</div>
      <div class="ab-card" id="ac-x">
```

Add `.player-mini-card` between `side-head` and `ab-card`:
```html
    <div class="side" id="side-x">
      <div class="side-head x" id="sh-x">— X —</div>
      <div class="player-mini-card x" id="pmc-x">
        <div class="pmc-sym">X</div>
        <div class="pmc-name" id="pmc-name-x">Player X</div>
        <div class="pmc-score" id="pmc-score-x">0</div>
        <div class="pmc-score-lbl">pts</div>
        <div class="pmc-turn" id="pmc-turn-x">
          <span class="pmc-dot"></span>
          <span id="pmc-turn-txt-x">YOUR TURN</span>
        </div>
        <div class="pmc-frozen" id="pmc-frozen-x">❄️ FROZEN</div>
      </div>
      <div class="ab-card" id="ac-x">
```

**Step 3: Verify in browser at <560px**

You should now see the mini cards appear on mobile with static content (O, Player O, 0 pts). No JS yet — that's fine.

---

## Task 3: Add `updateMiniCards()` JS function

**Files:**
- Modify: `index.html` — JS section, just after `updScFull()` function (around line 1787)

**Step 1: Locate insertion point**

Find `function renderAbs()` (around line 1789). Insert the new function immediately before it.

**Step 2: Add the function**

```javascript
function updateMiniCards() {
  for (const p of ['O', 'X']) {
    const lc = p.toLowerCase();
    const card      = document.getElementById(`pmc-${lc}`);
    const nameEl    = document.getElementById(`pmc-name-${lc}`);
    const scoreEl   = document.getElementById(`pmc-score-${lc}`);
    const turnEl    = document.getElementById(`pmc-turn-${lc}`);
    const turnTxt   = document.getElementById(`pmc-turn-txt-${lc}`);
    const frozenEl  = document.getElementById(`pmc-frozen-${lc}`);

    if (!card) continue;

    // Score
    scoreEl.textContent = scores[p] ?? 0;

    // Name label — mirrors lbl-o / lbl-x logic
    nameEl.textContent = document.getElementById(`lbl-${lc}`).textContent;

    // Active / turn state
    const isActive = !over && cur === p;
    const isFrozenP = frozen === p;

    card.className = `player-mini-card ${lc}${isActive ? ' active' : ''}`;

    // Frozen state overrides turn indicator
    frozenEl.className = `pmc-frozen${isFrozenP ? ' visible' : ''}`;

    if (isFrozenP) {
      turnEl.className = 'pmc-turn';
    } else {
      turnEl.className = `pmc-turn${isActive ? ' visible' : ''}`;
      // Turn text: bot or player
      const isBot = gameMode !== '2p' && gameMode !== 'online' && p === BOT;
      turnTxt.textContent = isBot ? (cur === p ? 'THINKING…' : '') : (p === 'O' ? 'YOUR TURN' : 'YOUR TURN');
    }
  }
}
```

Note: `BOT` is always `'X'` (defined as `const BOT = 'X'` in the existing code — verify at line ~1876 before implementation).

**Step 3: Wire `updateMiniCards()` into existing update hooks**

Find `updSc()` (around line 1776):
```javascript
function updSc() {
  document.getElementById('sc-o').className = `sc o${!over && cur==='O' ? ' active' : ''}`;
  document.getElementById('sc-x').className = `sc x${!over && cur==='X' ? ' active' : ''}`;
}
```
Add `updateMiniCards();` as the last line inside it.

Find `updScFull()` (around line 1781):
```javascript
function updScFull() {
  document.getElementById('pts-o').textContent = scores.O;
  document.getElementById('pts-x').textContent = scores.X;
  document.getElementById('pts-t').textContent = scores.tie;
  document.getElementById('sc-o').className = 'sc o';
  document.getElementById('sc-x').className = 'sc x';
}
```
Add `updateMiniCards();` as the last line inside it.

**Step 4: Wire into `setMode()` for name label sync**

Find `setMode()` (around line 1897). After the lines that update `lbl-o` and `lbl-x` (around line 1920–1921), add:
```javascript
  updateMiniCards();
```

**Step 5: Wire into online label section (around line 2904)**

After the lines:
```javascript
  document.getElementById('lbl-o').textContent = mySide==='O' ? t('lblYou') : t('lblOpponent');
  document.getElementById('lbl-x').textContent = mySide==='X' ? t('lblYou') : t('lblOpponent');
```
Add:
```javascript
  updateMiniCards();
```

**Step 6: Test in browser**

Open in browser at <560px width. Play a round:
- [ ] Active player's mini card glows (cyan for O, red for X)
- [ ] Score updates after each round win
- [ ] Turn indicator dot pulses when it's that player's turn
- [ ] Frozen player shows ❄️ FROZEN, hides turn dot
- [ ] Bot mode shows player name as "YOU" / "BOT" in mini card
- [ ] Online mode shows "YOU" / "OPPONENT"
- [ ] >560px: mini cards hidden, side-head visible as before

---

## Task 4: Light mode & i18n pass

**Files:**
- Modify: `index.html` — CSS light mode block + JS LANG strings

**Step 1: Verify light mode**

Toggle light mode (🌙 button). Check at <560px:
- [ ] Mini card background is white (panel)
- [ ] Text is dark (no invisible text)
- [ ] Glow borders still visible

The CSS already includes `body.light .player-mini-card` overrides added in Task 1. If anything looks off, adjust in the light mode block.

**Step 2: Verify Thai language**

Toggle to TH language. The `pmc-name` text pulls from `lbl-o`/`lbl-x` which are already translated by `setMode()` and the online section. No extra i18n work needed — confirm by toggling.

**Step 3: Commit all changes**

```bash
git add index.html
git commit -m "feat: add mobile player mini card with score and turn indicator"
```

---

## Task 5: Polish — frozen text i18n

**Files:**
- Modify: `index.html` — `updateMiniCards()` function

**Step 1: Update frozen text to use translation system**

In `updateMiniCards()`, the frozen element currently has static `❄️ FROZEN` from HTML. Update the JS to set it dynamically:

```javascript
frozenEl.textContent = t('frozen');   // uses existing LANG.en.frozen / LANG.th.frozen
```

Remove the hardcoded `❄️ FROZEN` text from the HTML mini card divs (both `#pmc-o` and `#pmc-x`), leaving them empty — JS will populate.

**Step 2: Verify in browser**

- Toggle to TH, trigger a freeze ability. Confirm ❄️ แช่แข็ง shows in mini card.

**Step 3: Final commit**

```bash
git add index.html
git commit -m "fix: use i18n string for frozen label in player mini card"
```

---

## Checklist

- [ ] Task 1: CSS added, mobile media query updated
- [ ] Task 2: HTML mini cards in both sidebars
- [ ] Task 3: `updateMiniCards()` wired into all update hooks
- [ ] Task 4: Light mode + Thai language verified
- [ ] Task 5: Frozen label uses i18n
