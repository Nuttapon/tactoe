# 🎮 TACTOE

> **"It's Tic-Tac-Toe, but chaos."**

**TACTOE** is a next-generation Tic-Tac-Toe game built entirely in a single HTML file — no dependencies, no build step. Every round is turbocharged with random **special tiles**, unique **abilities**, a fully synthesised **audio engine**, rich **particle effects**, and a capable **AI bot** with four distinct difficulty levels.

---

## 🌐 Live Demo

**[▶ Play Now → tactical-toe.netlify.app](https://tactical-toe.netlify.app/)**

[![Netlify Status](https://img.shields.io/badge/demo-live-brightgreen?logo=netlify)](https://tactical-toe.netlify.app/)

Or clone the repo and open `index.html` locally — no server required.

---

## ✨ Features at a Glance

| Feature | Details |
|---|---|
| 🗺️ Game Modes | 2-Player vs. Bot (Easy / Hard / Expert / Master) |
| 🎯 Special Tiles | Wall, Bomb, Freeze, Star (Wildcard) |
| ⚡ Abilities | Nuke, Shield, Swap, Extra Turn, Oracle |
| 🌍 Languages | English 🇺🇸 & Thai 🇹🇭 (full UI translation, real-time switching) |
| 🎨 Themes | Dark mode & Light mode (persisted across sessions) |
| 🔊 Audio | Fully synthesised sounds via Web Audio API (no audio files) |
| ✨ Visual FX | Canvas particle system — explosions, ice bursts, confetti rain |
| 💾 Persistence | Language & theme preferences saved to `localStorage` |
| 📱 Responsive | Works on desktop, tablet, and mobile |

---

## 🕹️ How to Play

### Basic Rules

It's still 3-in-a-row — but the board has surprises.

- **Player O** always goes first.
- Players take turns placing their symbol (O or X).
- First to complete a line of 3 across any row, column, or diagonal wins the round.
- Scores persist across rounds. Use **Next Round** to keep playing or **Reset All** to start fresh.

### 🗺️ Special Tiles

Each round, the board is randomly seeded with **1 Wall** + **1–2 special tiles** (never in the center).

| Tile | Icon | Effect |
|---|---|---|
| **Wall** | 🧱 | Permanently blocked — no one can place here |
| **Bomb** | 💣 | Landing here destroys a random adjacent cell (shielded cells are safe) |
| **Freeze** | ❄️ | Landing here freezes the opponent — they skip their next turn |
| **Star** (Wildcard) | ⭐ | An unclaimed Star counts as **either** player's cell in win detection |

> 💡 The Star tile is the most powerful item — any line containing an unclaimed Star can be completed by either player.

---

## ⚡ Ability System

At the start of each round, each player receives **one unique ability** chosen at random from the pool below. Every ability can only be used **once per round**.

| Ability | Icon | Cost | Effect |
|---|---|---|---|
| **Nuke** | 💥 | Costs your turn | Destroy one opponent's cell. Shielded cells block it. |
| **Shield** | 🛡️ | Costs your turn | Protect one of your cells from Nuke & Bomb blasts. |
| **Swap** | 🔄 | Costs your turn | Swap any two non-wall cells (can disrupt an opponent's line). |
| **Extra Turn** | ⚡ | Free (instant) | Place **twice** this turn — no turn cost. |
| **Oracle** | 🔮 | Free (no turn) | Convert a random Wall tile into a ⭐ Wildcard. |

> 🧠 **Strategy tip:** Oracle and Extra Turn are always advantageous since they cost no turn. Nuke, Shield, and Swap are powerful but sacrifice your placement.

---

## 🤖 Bot Difficulties

Play against the AI with four escalating difficulty levels.

### 🟡 Easy
- Picks a random valid cell (avoids Bomb tiles slightly).
- Has a **30% chance** to use its ability randomly.

### 🔴 Hard
- Uses **Minimax with alpha-beta pruning** for optimal cell selection.
- Makes strategic ability decisions based on threat detection:
  - **Nuke** when the human has 2-in-a-line.
  - **Shield** to protect its own near-winning cells.
  - **Swap** to displace human threats.

### 🟣 Expert
- Full Minimax with **positional weighting** (prefers center and corners).
- Has a small **8% "miss rate"** — still very strong, but feels human-like.
- Evaluates ability targets using minimax simulation for maximum accuracy.
- **Priority guard:** never wastes a cost-ability when it can win immediately.

### 👑 Grandmaster (Master)
- **Zero miss rate.** Perfectly optimal.
- Highest positional weights: strongly prefers center and corners.
- Uses the correct **turn-cost evaluation model** for all abilities — compares expected board score *after using the ability* vs *after placing normally* before committing.
- Uses Oracle only when it provably improves the post-placement score.
- The hardest human-beatable challenge.

---

## 🌍 Language Support

Click the **EN / TH** button (top-right) to switch the interface language instantly.

| Element | Translated |
|---|---|
| Mode labels, buttons | ✅ |
| Score labels, status messages | ✅ |
| Ability names & descriptions | ✅ |
| Special tile labels | ✅ |
| Game feed messages | ✅ |
| Round indicator | ✅ |

Language preference is **saved to `localStorage`** and restored on your next visit.

---

## 🎨 Visual & Audio Effects

### 🔊 Audio Engine (Web Audio API)
All sounds are **procedurally synthesised** — no audio files whatsoever.

| Event | Sound |
|---|---|
| Place a tile | Soft oscillator tone (O = higher, X = lower) |
| Bomb explosion | Deep noise blast + filter sweep |
| Freeze | Crystalline descending ice tones |
| Star wildcard | Ascending sparkle arpeggio |
| Win round | Major chord fanfare |
| Draw | Descending minor resolve |
| Nuke ability | Sawtooth zap + noise burst |
| Shield ability | Rising harmonic hum |
| Swap ability | Two crossing whoosh sweeps |
| Oracle ability | FM synthesis — mystical shimmer |

> 🔇 Click the speaker button (top-right) to mute/unmute at any time.

### ✨ Particle System
A pool-based canvas particle engine renders:
- **Explosions** (orange fire burst + board shake) for Bomb.
- **Ice crystal rays** + blue screen tint for Freeze.
- **Gold star rays** for Wildcard capture.
- **Red electric disintegration** for Nuke.
- **Confetti rain** for round win.
- **Floating labels** ("💥 BOOM!", "❄️ FROZEN!", "⭐ WILD!") that rise and fade.

---

## 🎛️ Controls

| Control | Action |
|---|---|
| Click a cell | Place your symbol (or target an active ability) |
| **Use Ability** button | Arm your ability (see ability panel on your side) |
| **Next Round** | Start the next round, keeping scores |
| **Reset All** | Reset scores, round counter, and board |
| 🔊 / 🔇 | Mute / Unmute sound |
| 🌙 / ☀️ | Toggle Dark / Light theme |
| EN / TH | Switch language |

---

## 🏗️ Technical Architecture

The entire game lives in **one self-contained `index.html`** file.

```
TACTOE (single index.html)
├── 1. Audio Engine     Web Audio API — oscillators, noise, FM synthesis
├── 2. Particle System  Canvas overlay — pool-based particle animation
└── 3. Game Logic
    ├── Board & Special Tile State
    ├── Turn Management (freeze, extra turn)
    ├── Win Detection (with Star wildcard support)
    ├── Ability System (Nuke, Shield, Swap, Extra, Oracle)
    ├── Bot Engine
    │   ├── Easy   — random move selection
    │   ├── Hard   — minimax + alpha-beta pruning
    │   ├── Expert — minimax + positional weights + 8% miss rate
    │   └── Master — perfect minimax + cost-aware ability evaluation
    └── i18n System (EN / TH, localStorage persistence)
```

**No frameworks. No dependencies. No build tools.**

---

## 🚀 Getting Started

### ▶ Just Play (Local, No Setup)

```bash
git clone https://github.com/Nuttapon/tactoe.git
open index.html   # or double-click the file
```

> ⚠️ **Note:** The `index.html` in this repo has Supabase credentials replaced with placeholders (`SUPA_URL_PLACEHOLDER` / `SUPA_KEY_PLACEHOLDER`). Opening it directly works for **all local game modes** (2P, Bot), but **Online mode requires the credentials below**.

---

### 🌐 Online Multiplayer Setup

Online mode uses [Supabase Realtime](https://supabase.com) for real-time room sync. To enable it you need your own free Supabase project.

#### Option A — Local dev with `dev.sh`

1. Create a **free** Supabase project at [supabase.com](https://supabase.com)
2. Go to **Settings → API** and copy your `Project URL` and `anon` key
3. Create `.env.local` in the repo root (already gitignored):

```bash
SUPA_URL=https://your-project.supabase.co
SUPA_KEY=your-anon-key
```

4. Run the dev helper script:

```bash
./dev.sh    # creates index.dev.html with keys injected and opens it
```

#### Option B — Deploy to Netlify

1. Fork this repo
2. Connect to [Netlify](https://netlify.com)
3. In **Site Settings → Environment Variables**, add:
   - `SUPA_URL` = your Supabase Project URL
   - `SUPA_KEY` = your Supabase anon key
4. Deploy — `netlify.toml` injects the keys automatically at build time

---

### 🎮 Playing Online

1. Click **🌐 Online** in the mode bar
2. **Host**: A room code is generated automatically → click **📋 Copy Invite Link** → send to your friend → choose timer (5 / 10 / 15s or Off) → wait
3. **Guest**: Open the invite link → room code is pre-filled → click **Join Room**
4. Game starts automatically — host plays as **O**, guest plays as **X**

---

## 🛠️ Browser Compatibility

Requires a modern browser with support for:
- `Web Audio API` (AudioContext)
- `Canvas 2D API`
- ES6+ (classes, arrow functions, destructuring, `Map`, `Set`)
- WebSocket (for online mode)

✅ Chrome, Edge, Firefox, Safari (latest versions)

---

## 📄 License

MIT — free to use, modify, and share.

---

## 🙏 Credits

**TACTOE** — Designed and developed by [Nuttapon](https://github.com/Nuttapon) · 2026

Fonts: [Rajdhani](https://fonts.google.com/specimen/Rajdhani) & [Share Tech Mono](https://fonts.google.com/specimen/Share+Tech+Mono) via Google Fonts.
