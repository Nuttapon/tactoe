# Reconnect, Ability Tooltip & Abilities Toggle — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add self-rejoin after disconnect, hover tooltip for targeted abilities, and an abilities on/off toggle in the host room settings.

**Architecture:** All changes are in a single `index.html` file. Features are independent and can be implemented sequentially. No test framework exists — each task ends with a manual verification checklist. Game state is synced via Supabase broadcast; new events `room:rejoin` and `room:sync` handle reconnect state transfer.

**Tech Stack:** Vanilla JS, HTML/CSS, Supabase Realtime (broadcast + presence)

---

## Task 1: Add i18n strings for all new UI

**Files:**
- Modify: `index.html` — `LANG.en` (line ~961) and `LANG.th` (line ~1026)

**Step 1: Add English strings**

Find the closing brace of `LANG.en` (the line that reads `rmJoinRoomDesc: 'Enter a code to join'`) and add before the `},` that closes `en:`:

```javascript
    rmSepAbilities:'Abilities',
    rmAbilitiesQuestion:'Enable player abilities?',
    rmAbilitiesOn:'On',
    rmAbilitiesOff:'Off',
    dcRejoin:'Rejoin',
    dcRejoining:'🔄 Reconnecting…',
    dcRejoinFailed:'❌ Could not reconnect',
    rejoinBannerMsg:'You have a game in progress.',
    rejoinBannerBtn:'Rejoin',
```

**Step 2: Add Thai strings**

Find the same closing position in `LANG.th` (after `rmJoinRoomDesc: 'ใส่รหัสเพื่อเข้าร่วม'`) and add:

```javascript
    rmSepAbilities:'ความสามารถ',
    rmAbilitiesQuestion:'เปิดใช้ความสามารถผู้เล่น?',
    rmAbilitiesOn:'เปิด',
    rmAbilitiesOff:'ปิด',
    dcRejoin:'กลับเข้าเกม',
    dcRejoining:'🔄 กำลังเชื่อมต่อใหม่…',
    dcRejoinFailed:'❌ เชื่อมต่อใหม่ไม่สำเร็จ',
    rejoinBannerMsg:'คุณมีเกมที่ยังเล่นค้างอยู่',
    rejoinBannerBtn:'กลับเข้าเกม',
```

**Step 3: Register static HTML elements in the i18n updater**

Find the block that maps element IDs to lang keys (around line 1076 — the section with `'dc-title':'dcTitle'`). Add inside that block:

```javascript
    'rm-sep-abilities':'rmSepAbilities',
    'rm-abilities-lbl':'rmAbilitiesQuestion',
```

**Step 4: Verify**
- Open the game in browser
- Click "TH" language button
- Open Online modal → Create Room → confirm no JS errors in console (the new keys won't show yet, that's fine)

**Step 5: Commit**
```bash
git add index.html
git commit -m "feat: add i18n strings for abilities toggle and reconnect UI"
```

---

## Task 2: Abilities Toggle — HTML in host section

**Files:**
- Modify: `index.html` — `#rm-host-section` HTML (line ~819–821)

**Step 1: Add toggle HTML after the Match Goal block**

Find this exact closing tag in `#rm-host-section`:

```html
      </div>
    </div>
```

The one that closes `#rm-goal-opts` and `#rm-host-section`. Insert before the closing `</div>` of `#rm-host-section`:

```html
      <div class="rm-sep" id="rm-sep-abilities">Abilities</div>
      <div class="rm-timer-lbl" id="rm-abilities-lbl">Enable player abilities?</div>
      <div class="rm-timer-opts" id="rm-abilities-opts">
        <button class="rm-t sel" onclick="setOnlineAbilities(true)" id="rm-abl-on">On</button>
        <button class="rm-t" onclick="setOnlineAbilities(false)" id="rm-abl-off">Off</button>
      </div>
```

The full context to match (use `old_string`):

```html
        <button class="rm-t sel" onclick="setOnlineGoal(0)">∞</button>
      </div>
    </div>
```

Replace with:

```html
        <button class="rm-t sel" onclick="setOnlineGoal(0)">∞</button>
      </div>
      <div class="rm-sep" id="rm-sep-abilities">Abilities</div>
      <div class="rm-timer-lbl" id="rm-abilities-lbl">Enable player abilities?</div>
      <div class="rm-timer-opts" id="rm-abilities-opts">
        <button class="rm-t sel" onclick="setOnlineAbilities(true)" id="rm-abl-on">On</button>
        <button class="rm-t" onclick="setOnlineAbilities(false)" id="rm-abl-off">Off</button>
      </div>
    </div>
```

**Step 2: Verify visually**
- Open game → Online → Create Room → host section should show "Abilities / Enable player abilities? / [On] [Off]" below Match Goal
- Both buttons render, "On" is highlighted (`.sel`)

**Step 3: Commit**
```bash
git add index.html
git commit -m "feat: add abilities toggle HTML to host room settings"
```

---

## Task 3: Abilities Toggle — JS variable, handler, init enforcement, renderAbs hide

**Files:**
- Modify: `index.html` — globals (line ~2849), `setOnlineAbilities()` new function, `init()` (~line 1508), `renderAbs()` (~line 2042), `room:ready` broadcast (~line 3025), guest `room:ready` handler (~line 3087)

**Step 1: Add `onlineAbilities` variable**

Find:
```javascript
let onlineTimer   = 10;     // seconds (configured by host)
```

Add after it:
```javascript
let onlineAbilities = true; // whether abilities are enabled in online match
```

**Step 2: Add `setOnlineAbilities()` function**

Find the `setOnlineGoal` function (around line 2996). Add right after its closing `}`:

```javascript
function setOnlineAbilities(enabled) {
  onlineAbilities = enabled;
  document.getElementById('rm-abl-on').classList.toggle('sel', enabled);
  document.getElementById('rm-abl-off').classList.toggle('sel', !enabled);
}
```

**Step 3: Enforce in `init()`**

Find in `init()`:
```javascript
  // Give each player a different random ability
  const sh = shuffle([...POOL]);
  ab = {
    O: { type:sh[0], used:false, active:false, ss:0, sf:-1, ep:false },
    X: { type:sh[1], used:false, active:false, ss:0, sf:-1, ep:false }
  };
```

Replace with:
```javascript
  // Give each player a different random ability (unless disabled)
  if (onlineAbilities !== false) {
    const sh = shuffle([...POOL]);
    ab = {
      O: { type:sh[0], used:false, active:false, ss:0, sf:-1, ep:false },
      X: { type:sh[1], used:false, active:false, ss:0, sf:-1, ep:false }
    };
  } else {
    ab = {
      O: { type:null, used:true, active:false, ss:0, sf:-1, ep:false },
      X: { type:null, used:true, active:false, ss:0, sf:-1, ep:false }
    };
  }
```

**Step 4: Hide cards in `renderAbs()` when type is null**

Find in `renderAbs()`:
```javascript
    const card = document.getElementById(`ac-${lc}`);
    const btn  = document.getElementById(`ab-${lc}`);
    const glow = a.active ? (p==='O' ? 'go' : 'gx') : '';
    card.className = `ab-card${a.used ? ' used' : ''}${glow ? ' '+glow : ''}`;
```

Replace with:
```javascript
    const card = document.getElementById(`ac-${lc}`);
    const btn  = document.getElementById(`ab-${lc}`);
    if (a.type === null) { card.style.display = 'none'; continue; }
    card.style.display = '';
    const glow = a.active ? (p==='O' ? 'go' : 'gx') : '';
    card.className = `ab-card${a.used ? ' used' : ''}${glow ? ' '+glow : ''}`;
```

**Step 5: Include `abilitiesEnabled` in `room:ready` broadcast**

Find:
```javascript
          broadcastOnline('room:ready', { timerSecs: onlineTimer, matchGoal: matchGoal });
```

Replace with:
```javascript
          broadcastOnline('room:ready', { timerSecs: onlineTimer, matchGoal: matchGoal, abilitiesEnabled: onlineAbilities });
```

**Step 6: Apply `abilitiesEnabled` in guest `room:ready` handler**

Find in guest `joinRoom()` handler for `case 'room:ready':`:
```javascript
          onlineTimer = payload.timerSecs;
          if (typeof payload.matchGoal === 'number') {
```

Replace with:
```javascript
          onlineTimer = payload.timerSecs;
          if (typeof payload.abilitiesEnabled === 'boolean') {
            onlineAbilities = payload.abilitiesEnabled;
          }
          if (typeof payload.matchGoal === 'number') {
```

**Step 7: Verify**
- Host: Create Room → set Abilities to "Off" → wait for guest to join
- Guest joins → both players should see NO ability cards
- Host: Create Room → leave Abilities "On" → both players should see ability cards as normal
- Local 2P mode: abilities still work (onlineAbilities defaults to `true`, only changed by host/guest flow)

**Step 8: Commit**
```bash
git add index.html
git commit -m "feat: implement abilities on/off toggle for online room settings"
```

---

## Task 4: Reconnect — Session persistence in localStorage

**Files:**
- Modify: `index.html` — `hostRoom()` (~line 3012), `joinRoom()` (~line 3079), `dcGiveUp()` (~line 3180), `setMode()` (~line 2151)

**Step 1: Save session on host**

Find in `hostRoom(id)`:
```javascript
function hostRoom(id) {
  initSupa(); mySide = 'O';
```

Replace with:
```javascript
function hostRoom(id) {
  initSupa(); mySide = 'O';
  localStorage.setItem('ttt_session', JSON.stringify({ roomId: id, side: 'O' }));
```

**Step 2: Save session on guest**

Find in `joinRoom(id)`:
```javascript
function joinRoom(id) {
  initSupa(); mySide = 'X';
  setOnlineStatus(t('rmConnecting'));
```

Replace with:
```javascript
function joinRoom(id) {
  initSupa(); mySide = 'X';
  localStorage.setItem('ttt_session', JSON.stringify({ roomId: id, side: 'X' }));
  setOnlineStatus(t('rmConnecting'));
```

**Step 3: Clear session on give up**

Find:
```javascript
function dcGiveUp() {
  clearDisconnect();
  setMode('2p');
}
```

Replace with:
```javascript
function dcGiveUp() {
  localStorage.removeItem('ttt_session');
  clearDisconnect();
  setMode('2p');
}
```

**Step 4: Clear session when leaving online via setMode**

Find in `setMode(m)`:
```javascript
  if (m !== 'online') {
    onlineMode = false; mySide = null;
    if (onlineChannel) { onlineChannel.unsubscribe(); onlineChannel = null; }
```

Replace with:
```javascript
  if (m !== 'online') {
    localStorage.removeItem('ttt_session');
    onlineMode = false; mySide = null;
    if (onlineChannel) { onlineChannel.unsubscribe(); onlineChannel = null; }
```

**Step 5: Verify**
- Open DevTools → Application → Local Storage
- Click Online → Create Room → confirm `ttt_session` key appears with `{ roomId, side:'O' }`
- Click Cancel → confirm `ttt_session` is removed (closeOnlineModal already handles this via the Bug 1 fix)
- Open Online → Create Room → Guest joins → click "Return to Menu" → confirm `ttt_session` removed

**Step 6: Commit**
```bash
git add index.html
git commit -m "feat: persist online session to localStorage for reconnect support"
```

---

## Task 5: Reconnect — Rejoin button UI, dcRejoin(), broadcast handlers

**Files:**
- Modify: `index.html` — `#dc-ov` HTML (~line 841), CSS (~line 603), `handleDisconnect()` (~line 3152), `dcRejoin()` new function, host broadcast handler (~line 3019), guest broadcast handler (~line 3087)

**Step 1: Add Rejoin button to `#dc-ov` HTML**

Find:
```html
  <button class="dc-btn" id="dc-btn" onclick="dcGiveUp()">Return to Menu</button>
```

Replace with:
```html
  <button class="dc-btn" id="dc-btn" onclick="dcGiveUp()">Return to Menu</button>
  <button class="dc-btn dc-btn-rejoin" id="dc-rejoin-btn" onclick="dcRejoin()" style="display:none">Rejoin</button>
```

**Step 2: Add CSS for rejoin button (styled like dc-btn but primary color)**

Find:
```css
.dc-btn:hover{ background:rgba(255,51,85,.2); }
```

Add after it:
```css
.dc-btn-rejoin{ border-color:var(--o); color:var(--o); background:rgba(0,200,255,.1); }
.dc-btn-rejoin:hover{ background:rgba(0,200,255,.2); }
```

**Step 3: Show Rejoin button when countdown hits zero in `handleDisconnect()`**

Find:
```javascript
    if (cd <= 0) {
      clearInterval(dcInterval);
      btn.style.display = 'block';
      cdEl.textContent = t('connLost');
    }
```

Replace with:
```javascript
    if (cd <= 0) {
      clearInterval(dcInterval);
      btn.style.display = 'block';
      const rejoinBtn = document.getElementById('dc-rejoin-btn');
      if (localStorage.getItem('ttt_session')) rejoinBtn.style.display = 'block';
      cdEl.textContent = t('connLost');
    }
```

**Step 4: Add `dcRejoin()` function**

Add right after the `dcGiveUp()` function:

```javascript
function dcRejoin() {
  const raw = localStorage.getItem('ttt_session');
  if (!raw) { dcGiveUp(); return; }
  const { roomId, side } = JSON.parse(raw);
  mySide = side;
  const cdEl = document.getElementById('dc-cd');
  const rejoinBtn = document.getElementById('dc-rejoin-btn');
  const giveUpBtn = document.getElementById('dc-btn');
  cdEl.textContent = t('dcRejoining');
  rejoinBtn.style.display = 'none';
  giveUpBtn.style.display = 'none';

  // Unsubscribe old channel if any
  if (onlineChannel) { onlineChannel.unsubscribe(); onlineChannel = null; }

  // Resubscribe to the same channel
  initSupa();
  onlineChannel = sbClient.channel(`tactoe:${roomId}`, {
    config: { presence: { key: mySide } }
  })
    .on('broadcast', { event:'*' }, ({ event, payload }) => {
      if (payload.sender === mySide) return;
      if (event === 'room:sync') {
        applyNetState(payload.state);
        render(); renderAbs();
        clearDisconnect();
        updateOnlineTurnTimer();
      }
    })
    .on('presence', { event: 'leave' }, ({ leftPresences }) => {
      if (leftPresences.some(p => p.side !== mySide)) handleDisconnect();
    })
    .on('presence', { event: 'join' }, ({ newPresences }) => {
      if (newPresences.some(p => p.side !== mySide)) clearDisconnect();
    })
    .subscribe(async (status) => {
      if (status === 'SUBSCRIBED') {
        await onlineChannel.track({ side: mySide });
        broadcastOnline('room:rejoin');
      }
    });

  // Timeout: if no room:sync in 5s, show failure
  const rejoinTimeout = setTimeout(() => {
    if (document.getElementById('dc-ov').classList.contains('show')) {
      cdEl.textContent = t('dcRejoinFailed');
      giveUpBtn.style.display = 'block';
    }
  }, 5000);

  // Store timeout ID so room:sync handler can clear it
  window._rejoinTimeout = rejoinTimeout;
}
```

**Step 5: Clear rejoin timeout in `room:sync` handler inside `dcRejoin()`**

Find the line in dcRejoin's broadcast handler:
```javascript
        clearDisconnect();
        updateOnlineTurnTimer();
```

Replace with:
```javascript
        if (window._rejoinTimeout) { clearTimeout(window._rejoinTimeout); window._rejoinTimeout = null; }
        clearDisconnect();
        updateOnlineTurnTimer();
```

**Step 6: Handle `room:rejoin` in HOST broadcast handler**

Find in `hostRoom()` switch statement, after `case 'game:rematch':` block closing `break;` and before the `}` that closes the switch:

```javascript
        case 'game:emote': showEmoteBubble(payload.emoji, payload.sender); break;
```

The switch in hostRoom already has a default fall-through. Add `room:rejoin` and `room:sync` cases. Find this line in hostRoom:

```javascript
        case 'game:emote': showEmoteBubble(payload.emoji, payload.sender); break;
```

Replace with:
```javascript
        case 'game:emote': showEmoteBubble(payload.emoji, payload.sender); break;
        case 'room:rejoin':
          clearDisconnect();
          broadcastOnline('room:sync');
          break;
        case 'room:sync': break; // host ignores sync (it sent it)
```

**Step 7: Handle `room:rejoin` in GUEST broadcast handler**

Find the same `case 'game:emote':` line in `joinRoom()` switch:

```javascript
        case 'game:emote': showEmoteBubble(payload.emoji, payload.sender); break;
```

Replace with:
```javascript
        case 'game:emote': showEmoteBubble(payload.emoji, payload.sender); break;
        case 'room:rejoin':
          clearDisconnect();
          broadcastOnline('room:sync');
          break;
        case 'room:sync': break; // guest ignores sync (it sent it)
```

**Step 8: Verify**
- Open game in two tabs (Tab A = host, Tab B = guest)
- Start a game
- In Tab B: open DevTools → Network → disconnect from network (or kill the tab and reopen)
- Tab A should show disconnect overlay with 10s countdown
- After 10s: "Return to Menu" and "Rejoin" buttons appear
- Restore network in Tab B (or reopen) — Rejoin button click in Tab A → overlay disappears, game resumes
- Verify state is correct (board, scores, whose turn)

**Step 9: Commit**
```bash
git add index.html
git commit -m "feat: add rejoin button and dcRejoin() for self-disconnect recovery"
```

---

## Task 6: Reconnect — Page-load rejoin banner

**Files:**
- Modify: `index.html` — HTML near top of `<body>` (after `#dc-ov`), CSS, and script initialization

**Step 1: Add banner HTML**

Find:
```html
<!-- Game start animation overlay -->
```

Add before it:
```html
<!-- Rejoin banner (shown on page load if localStorage has active session) -->
<div id="rejoin-banner" style="display:none">
  <span id="rejoin-banner-msg"></span>
  <button onclick="dcRejoin()">Rejoin</button>
  <button onclick="dismissRejoinBanner()">✕</button>
</div>
```

**Step 2: Add CSS for rejoin banner**

Find:
```css
#start-ov{
```

Add before it:
```css
#rejoin-banner{ position:fixed; top:0; left:0; right:0; z-index:9000;
  background:rgba(0,200,255,.15); border-bottom:1px solid var(--o);
  display:flex; align-items:center; justify-content:center; gap:12px;
  padding:10px 16px; font-family:var(--font); font-size:.8rem; color:#fff; }
#rejoin-banner button{ font-family:var(--font); font-size:.75rem; font-weight:700;
  padding:5px 14px; border-radius:7px; border:1px solid var(--o); cursor:pointer;
  background:rgba(0,200,255,.2); color:var(--o); letter-spacing:.05em; }
#rejoin-banner button:last-child{ border-color:#555; color:#888; background:transparent; }
```

**Step 3: Add `dismissRejoinBanner()` and page-load check**

Find the `dcGiveUp()` function (which you already modified). Add after `dcRejoin()`:

```javascript
function dismissRejoinBanner() {
  localStorage.removeItem('ttt_session');
  document.getElementById('rejoin-banner').style.display = 'none';
}
```

**Step 4: Add page-load check**

Find the very end of the `<script>` block (look for the last `</script>` tag, just before it find the last few lines of JS). Anywhere near the end of the JS (after all function definitions), add:

```javascript
/* ── Page-load: check for abandoned session ─────────────── */
(function checkRejoinSession() {
  const raw = localStorage.getItem('ttt_session');
  if (!raw) return;
  const banner = document.getElementById('rejoin-banner');
  document.getElementById('rejoin-banner-msg').textContent = t('rejoinBannerMsg');
  banner.querySelector('button').textContent = t('rejoinBannerBtn');
  banner.style.display = 'flex';
})();
```

**Step 5: Verify**
- Open game, create a room as host → confirm `ttt_session` in localStorage
- Refresh the page → banner appears at top: "You have a game in progress. [Rejoin] [✕]"
- Click ✕ → banner disappears, localStorage cleared
- Refresh again → no banner

**Step 6: Commit**
```bash
git add index.html
git commit -m "feat: add page-load rejoin banner when localStorage session exists"
```

---

## Task 7: Ability Hover Tooltip — HTML & CSS

**Files:**
- Modify: `index.html` — HTML (near `#dc-ov`), CSS

**Step 1: Add tooltip div**

Find:
```html
<!-- Disconnect overlay -->
```

Add before it:
```html
<!-- Ability cell hover tooltip -->
<div id="cell-tooltip" style="display:none"></div>
```

**Step 2: Add CSS**

Find `.dc-btn:hover{ background:rgba(255,51,85,.2); }` (or anywhere in the CSS block). Add:

```css
#cell-tooltip{ position:fixed; z-index:7000; pointer-events:none;
  background:rgba(5,10,20,.92); border:1px solid rgba(255,255,255,.15);
  border-radius:8px; padding:5px 10px; font-family:var(--font);
  font-size:.72rem; font-weight:600; letter-spacing:.05em; color:#fff;
  white-space:nowrap; opacity:0; transition:opacity .12s; }
#cell-tooltip.visible{ opacity:1; }
```

**Step 3: Verify**
- No visual change yet (tooltip is hidden)
- No JS errors in console

**Step 4: Commit**
```bash
git add index.html
git commit -m "feat: add cell-tooltip HTML and CSS for ability hover preview"
```

---

## Task 8: Ability Hover Tooltip — JS logic

**Files:**
- Modify: `index.html` — `buildBoard()` (~line 1533), new functions `showCellTooltip()` and `hideCellTooltip()`

**Step 1: Add `showCellTooltip()` and `hideCellTooltip()` functions**

Find the `renderAbs()` function. Add these two functions right before it:

```javascript
/* ── Ability cell hover tooltip ───────────────────────────── */
function showCellTooltip(i, el) {
  // Determine which player's ability is armed
  const p = ab.O.active ? 'O' : ab.X.active ? 'X' : null;
  if (!p) return;
  const a = ab[p];
  let txt = '';

  if (a.type === 'nuke') {
    const cell = board[i];
    if (!cell || cell.p === p) return; // can't nuke own/empty
    txt = cell.sh ? `🛡️ Shielded — Nuke blocked` : `💥 Nuke this cell`;
  } else if (a.type === 'shield') {
    const cell = board[i];
    if (!cell || cell.p !== p) return; // can only shield own piece
    txt = `🛡️ Shield this cell`;
  } else if (a.type === 'swap') {
    if (specials[i] === 'wall') return;
    txt = a.ss === 0 ? `🔄 Swap FROM here` : `🔄 Swap TO here`;
  } else {
    return;
  }

  const tip = document.getElementById('cell-tooltip');
  tip.textContent = txt;
  tip.style.display = 'block';
  const rect = el.getBoundingClientRect();
  tip.style.left = `${rect.left + rect.width / 2}px`;
  tip.style.top  = `${rect.top - 36}px`;
  tip.style.transform = 'translateX(-50%)';
  requestAnimationFrame(() => tip.classList.add('visible'));
}

function hideCellTooltip() {
  const tip = document.getElementById('cell-tooltip');
  tip.classList.remove('visible');
  setTimeout(() => { if (!tip.classList.contains('visible')) tip.style.display = 'none'; }, 120);
}
```

**Step 2: Wire tooltip events in `buildBoard()`**

Find:
```javascript
    c.addEventListener('click', () => click(i));
```

Replace with:
```javascript
    c.addEventListener('click', () => click(i));
    c.addEventListener('mouseenter', () => showCellTooltip(i, c));
    c.addEventListener('mouseleave', hideCellTooltip);
```

**Step 3: Clear tooltip when ability is cancelled or used**

Find `hideCellTooltip` and also call it from ability cancel. Find in `useAbility()` or `abilTarget()` where ability is cancelled. Search for `sndCancel()`:

```javascript
    a.active = false; a.ss = 0; a.sf = -1;
    clearTgt(); sndCancel(); log(`${p} cancelled ability.`); renderAbs(); return;
```

Replace with:
```javascript
    a.active = false; a.ss = 0; a.sf = -1;
    clearTgt(); hideCellTooltip(); sndCancel(); log(`${p} cancelled ability.`); renderAbs(); return;
```

**Step 4: Verify**
- Start a 2P game
- Click "Use Ability" for Player O (any targeted ability: nuke, shield, swap)
- Hover over board cells → tooltip should appear above each valid target
  - Nuke: hover opponent cell → "💥 Nuke this cell"; hover shielded cell → "🛡️ Shielded — Nuke blocked"; hover own/empty → no tooltip
  - Shield: hover own piece → "🛡️ Shield this cell"; hover other cells → no tooltip
  - Swap: hover any non-wall cell → "🔄 Swap FROM here"; after first selection, hover again → "🔄 Swap TO here"
- Cancel ability → tooltip disappears

**Step 5: Verify online**
- Online match: ability tooltip only appears when it's `mySide`'s turn and their ability is armed

**Step 6: Commit**
```bash
git add index.html
git commit -m "feat: add ability hover tooltip with context-aware cell targeting preview"
```

---

## Final Verification Checklist

Run through all scenarios:

**Abilities Toggle:**
- [ ] Host creates room with Abilities "Off" → both players see no ability cards
- [ ] Host creates room with Abilities "On" (default) → both players see ability cards
- [ ] 2P local mode unaffected (abilities always on)
- [ ] Bot modes unaffected

**Reconnect:**
- [ ] Host creates room → localStorage has `ttt_session`
- [ ] Cancel room → localStorage cleared
- [ ] Guest joins, host gives up (Return to Menu) → localStorage cleared
- [ ] Tab B disconnects → Tab A sees countdown → after 10s, Rejoin + Return to Menu appear
- [ ] Tab B rejoins → Tab A clicks Rejoin → game state restored correctly
- [ ] Page refresh while in active game → rejoin banner appears
- [ ] Banner ✕ → localStorage cleared, no banner next load

**Ability Tooltip:**
- [ ] Nuke armed: hover opponent cell shows correct tooltip (blocked if shielded)
- [ ] Shield armed: hover own piece shows shield tooltip
- [ ] Swap armed: first pick shows "FROM", second pick shows "TO"
- [ ] Extra/Oracle: no tooltip (non-targeted abilities)
- [ ] Tooltip disappears on mouseleave and on ability cancel

**Final Commit:**
```bash
git add index.html
git commit -m "feat: complete reconnect, ability tooltip, and abilities toggle features"
```
