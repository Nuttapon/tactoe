# Design: Reconnect, Ability Hover Tooltip, Custom Room Settings (Abilities Toggle)

**Date**: 2026-02-22
**File**: `index.html`

---

## Feature 1 — Reconnect (Self-rejoin)

### Problem
If the local player disconnects (network drop, page refresh, browser crash), there is no way to rejoin the same game. The opponent sees the 10-second disconnect countdown and is forced to give up.

### Design

**State persistence**
- On `hostRoom(id)`: `localStorage.setItem('ttt_session', JSON.stringify({ roomId: id, side: 'O' }))`
- On `joinRoom(id)`: same with `side: 'X'`
- On `dcGiveUp()`, `closeOnlineModal()` (non-online), or match fully complete: `localStorage.removeItem('ttt_session')`

**Disconnect overlay — new Rejoin button**
- Add a primary "Rejoin" button to the existing `#dc-ov` overlay, alongside the existing "Return to Menu" button
- Clicking Rejoin triggers `dcRejoin()`

**Rejoin flow (`dcRejoin()`)**
1. Read `{ roomId, side }` from localStorage
2. Unsubscribe existing channel if any, re-subscribe to `tactoe:{roomId}`
3. On `SUBSCRIBED`: broadcast `room:rejoin`
4. Set 5-second timeout — if no `room:sync` received, show error "Could not reconnect"

**New broadcast events**
| Event | Direction | Payload | Action |
|-------|-----------|---------|--------|
| `room:rejoin` | Rejoined → Opponent | `{ sender }` | Opponent responds with `room:sync` |
| `room:sync` | Opponent → Rejoined | `{ sender, state }` | `applyNetState(state)` + resume UI |

**Opponent handler for `room:rejoin`**
- Call `clearDisconnect()` (clear the countdown on opponent's side)
- Broadcast `room:sync` with current `getNetState()`

**Page-load banner**
- On page load: if `localStorage.getItem('ttt_session')` exists, show a subtle banner "You have a game in progress — Rejoin?" with a Rejoin button
- Rejoin from banner: same `dcRejoin()` flow

**Cleanup**
- On successful `room:sync`: clear the 5-second timeout, `clearDisconnect()`, resume turn timer

---

## Feature 2 — Ability Hover Tooltip

### Problem
When a player arms an ability and clicks a target cell, it's not immediately clear what will happen to that specific cell. The description in the ability card is generic.

### Design

**New HTML element**
```html
<div id="cell-tooltip" style="display:none"></div>
```
Positioned fixed/absolute, z-index above board.

**Trigger**
In `createBoard()`, add `onmouseenter` and `onmouseleave` to each cell element.

`onmouseenter(i)` → calls `showCellTooltip(i, event)`
`onmouseleave()` → calls `hideCellTooltip()`

**`showCellTooltip(i, e)`**
- Only active when `ab[mySide].active === true` (or in 2P mode, the current player's ability)
- Look up ability type and cell state to generate text:

| Ability | Cell state | Tooltip text |
|---------|-----------|--------------|
| `nuke` | opponent piece, no shield | `💥 Nuke this cell` |
| `nuke` | opponent piece, shielded | `🛡️ Shielded — Nuke blocked` |
| `shield` | own piece | `🛡️ Shield this cell` |
| `swap` | ss=0 (picking first) | `🔄 Swap FROM here` |
| `swap` | ss=1 (picking second) | `🔄 Swap TO here` |
| any | non-targetable cell | (no tooltip) |

- Position tooltip relative to the hovered cell using `getBoundingClientRect()`
- Clear tooltip on ability cancel/use or `onmouseleave`

---

## Feature 3 — Abilities Toggle (Custom Room Settings)

### Problem
Host cannot disable player abilities. Players who want a pure Tic-Tac-Toe experience (no nuke/shield/swap/extra/oracle) have no option.

### Design

**New variable**
```javascript
let onlineAbilities = true; // default: abilities enabled
```

**New host UI** (added after the Match Goal section in `#rm-host-section`):
```html
<div class="rm-sep" id="rm-sep-abilities">Abilities</div>
<div class="rm-timer-lbl" id="rm-abilities-lbl">Enable player abilities?</div>
<div class="rm-timer-opts" id="rm-abilities-opts">
  <button class="rm-t sel" onclick="setOnlineAbilities(true)">On</button>
  <button class="rm-t" onclick="setOnlineAbilities(false)">Off</button>
</div>
```

**`setOnlineAbilities(enabled)`**
- Sets `onlineAbilities = enabled`
- Updates `.sel` class on the two buttons

**`room:ready` payload**
Add `abilitiesEnabled: onlineAbilities` to the broadcast.

**Guest handler**
```javascript
if (typeof payload.abilitiesEnabled === 'boolean') {
  onlineAbilities = payload.abilitiesEnabled;
}
```

**`init()` enforcement**
```javascript
if (!onlineAbilities) {
  ab = {
    O: { type: null, used: true, active: false, ss: 0, sf: -1, ep: false },
    X: { type: null, used: true, active: false, ss: 0, sf: -1, ep: false }
  };
}
```

**`renderAbs()` — hide cards when disabled**
```javascript
const card = document.getElementById(`ac-${lc}`);
card.style.display = a.type === null ? 'none' : '';
```

**i18n**: Add `rm-sep-abilities` / `rm-abilities-lbl` keys for Thai/English translation strings.

---

## Files Changed

| File | Area |
|------|------|
| `index.html` | HTML: `#dc-ov`, `#rm-host-section`, `#cell-tooltip` |
| `index.html` | JS: `dcRejoin()`, `setOnlineAbilities()`, `showCellTooltip()`, `hideCellTooltip()`, `hostRoom()`, `joinRoom()`, `dcGiveUp()`, `closeOnlineModal()`, `init()`, `renderAbs()`, `createBoard()`, broadcast handlers |
| `index.html` | CSS: `#cell-tooltip` styles |
| `index.html` | i18n: Thai/English strings for new UI labels |
