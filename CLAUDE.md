# CLAUDE.md

Guidance for working in this repository.

## What this is

A **Vampire Survivors–style** auto-battler built in **Godot 4.6** (Forward Plus). Pick
a map, then a character; move with WASD/arrows while weapons auto-fire at the nearest
enemy. Runs are a fixed **7 minutes** with boss milestones, extraction gates, and a
dual-currency meta shop between runs.

The game is **bilingual**: `lang = 0` is Vietnamese (default), `lang = 1` is English.
All player-facing strings live in the `I18N` dictionary in `game.gd` as `[vi, en]`
pairs, read via the `T(key)` helper. **Source-code comments are written in Vietnamese.**

## Running & verifying

No build script or test suite. Open the project in the Godot 4.6 editor and run (`F5`),
or run `scenes/main.tscn`. `.godot/` (import cache) is gitignored.

Useful headless commands (the Godot binary lives at
`/Applications/Godot.app/Contents/MacOS/Godot` on this machine):

```sh
# Syntax-check a script after editing (run from the repo root)
Godot --headless --path . --check-only --script scripts/game.gd
# Import newly added assets (required before preload() of a new file resolves)
Godot --headless --path . --import
```

⚠️ If the Godot editor is open while files are edited externally, accept its **Reload**
prompt — saving a stale editor buffer has previously overwritten disk changes.

Persistent state in `user://`: `settings.cfg` (language), `save.cfg` (gold, souls,
upgrade levels, `unlocked_maps`, `ronin_unlocked`).

## Architecture — read this first

The scene tree is **deliberately minimal**. `scenes/main.tscn` contains only:

```
Main (Node2D, game.gd)
├── Player (CharacterBody2D, player.gd) — Sprite2D, Camera2D, CollisionShape2D
└── UI (CanvasLayer) — HP/XP bars, labels, level-up panel, character-select panel,
					   settings panel, buttons (built-in nodes only)
```

**Almost every other game object is created in code, not as a `.tscn`.** Enemies,
bosses, projectiles, gems, coins, pickups, crates, hazards, and most UI panels (map
select, shop, chest, pause, debug) are instantiated with `Area2D.new()` /
`Node2D.new()` / `Button.new()` and given behavior via `node.set_script(SOME_SCRIPT)`.
When adding a new entity, follow the same pattern: `new()` the node, `set_script()`,
set its `var` fields, `add_child()`, then position it.

Objects coordinate through **signals** and **node groups**:
- Groups: `"enemies"`, `"gems"`, `"coins"`, `"crates"`, `"announce"`.
- Signals: enemies emit `died` / `summon` / `tornado` / `quicksand`; gems & coins emit
  `collected`; pickups emit `taken`; crates emit `broke`; the extraction gate emits
  `extracted` / `expired`; player emits `died`. `game.gd` wires these in
  `_make_enemy()` and the `_spawn_*` functions.

**Pausing**: menus set `get_tree().paused = true`. Nodes that must keep working while
paused (UI panels, music, SFX players for menu sounds, ESC/nav listeners) set
`process_mode = Node.PROCESS_MODE_ALWAYS`.

## Files

| File | Role |
|------|------|
| `scripts/game.gd` (~2700 lines) | **Central controller** on `Main`. Run/boss pacing, spawning, map hazards, level-up flow, milestones (cores/forms), artifacts, meta shop, economy, I18N, music/SFX, all code-built UI panels. Start here. |
| `scripts/player.gd` (~780) | Movement, auto-aim/fire, all weapons (incl. katana melee), signature stats, `take_damage`/`heal`, Thorn Charm burst, camera shake, hurt FX. |
| `scripts/enemy.gd` (~460) | Enemy + boss AI. `Kind` = MELEE/RANGER/BOSS; `State` = CHASE/TELEGRAPH/DASH. Elite mods, status effects (slow/freeze/poison/burn/frost — burn & frost are separate, stacking DoTs), boss skills, damage numbers, Dead-Zone revive. |
| `scripts/projectile.gd` (~240) | Player bullets: pierce, AoE + splash falloff, black hole vortex, execute, burn/shock/slow/freeze, trails. |
| `scripts/familiar.gd` (~240) | Spirit familiar: orbits, auto-fires, 8s-charge **Nova** (38 dmg, 100 px). `_make_anim_sprite` helper for atlas animations. |
| `scripts/extraction_gate.gd` | Post-mini-boss escape gate: 30s lifetime, 3s channel. |
| `scripts/gem.gd` / `scripts/coin.gd` | XP gems / gold coins; magnet pull, elite gems worth 5. |
| `scripts/pickup.gd` / `scripts/crate.gd` | Floor drops (heal/magnet/bomb) and breakable crates. |
| `scripts/tornado.gd` / `scripts/quicksand.gd` | Desert hazards (also used ambiently, not just by the boss). |
| `scripts/enemy_projectile.gd` / `scripts/boomerang.gd` | Enemy bullets; boomerang weapon. |
| `scripts/levelup_nav.gd` / `scripts/pause_listener.gd` | Keyboard nav (WASD+Space, R) and ESC listener for paused menus. |
| `scripts/virtual_joystick.gd` | Touch joystick scaffold — **not wired into any scene yet** (mobile WIP). |
| `tools/export_game_data.gd` | Editor tool to dump balance tables. |

## Run structure & pacing (game.gd)

- **Flow**: map select → character select (+shop) → 7-minute run.
- **Bosses**: `MINIBOSS_TIMES := [120, 240, 330]`, `FINAL_TIME := 420`. Boss HP is
  `220 + time*2.5`; the final boss multiplies HP ×2.0 (Dead Zone ×2.4) and DPS
  ×1.4/×2.0. Mini-boss kills open an **extraction gate**; the final-boss kill wins the
  run (`_win_run`) and unlocks the next map (clearing Desert also unlocks Ronin).
- **Rewards**: win/extract keep 100% of `run_gold`/`run_souls`; death keeps **25%
  gold, 50% souls** (`_on_player_died`). Souls drop only from bosses (mini 2, final
  8–12). Coins drop from every kill (value = gem count) and crates.
- **Spawning** (`_process`): interval `maxf(0.35, 1.1 - time*0.015)` (floor from
  ~50s). Variety unlocks: runner `t>18`, ranger `t>28`, tank `t>45`; elites 6% of
  melee after 45s with mods regen/split/explode/**shield** (blocks 3 show_dmg hits;
  DoT bypasses) /**vampire** (heals 2× contact damage dealt). Speed caps: melee
  **170**, runner **230**. After `t>210` every enemy drops **+1 gem**. Kill streaks
  show a combo counter (breaks after 1.5s; every 25 drops a bonus coin).
- **Characters** (5): Commando/shotgun, Grandpa/cannon, Hunter/sniper,
  Ronin/katana (unlock: clear Desert), **Agent/smg (unlock: clear Dead Zone)** —
  lock flags via `"unlock"` key + `_char_unlocked`. A virtual touch joystick
  (`virtual_joystick.gd`) is instantiated in `_ready` and read by `player.gd` when
  touched; keyboard/mouse unaffected.
- **Leveling**: `xp_needed = int(xp_needed * 1.10) + 4`. Milestones: **10** = weapon
  Core, **15** = Core enhance, **20** = Form (`soulburst` / `shock`), **25** =
  Ultimate. Expected timing: core ~1:00, enhance ~2:45, form ~5:00, ultimate ~8:00
  (pre-final only with the XP artifact).
- **Cores** (`SIG_CORES`): shotgun `burn`/`pierce`, cannon `blackhole`/`lava`,
  sniper `pierce`/`execute`, katana `wave`/`berserk` (+15% base damage). The Magma
  core (`lava`) makes every cannon blast leave a burning pool — 12 dmg/s (×1.6 and
  4s after enhance), radius = blast AoE, ticked by `game._lava_tick` over the
  `lava_pools` array; pools damage enemies without damage labels.
- **Forms**: `soulburst` — kills explode (18 dmg × `sig_dmg_mul`, 100 px, chains, no
  damage numbers to avoid label spam); `shock` — hits slow enemies (and thus enable
  the Exploit card).

## Map hazards (replaces the removed rain system)

All three maps share ONE cadence (`_hazard_tick`): a lone hazard every **4–8s** from
the very start of the run, plus full storms (**12–18s**, one burst every **0.7–1.1s**)
from ~1:00 with 40–55s calm between them (shrinking late). Payloads differ per map
(`_hazard_single` / `_hazard_burst`); the extraction gate area is never targeted and
there are no banner announcements — weather just happens.

- **Meadow — thunderstorms**: single strike (calm) / 2–3 staggered strikes (storm).
  Each strike: 0.9s warning ring, 90 px, 25 dmg to player, **30 dmg to enemies** —
  strikes can be baited. Distinct thunder SFX + golden bolt/spark/scorch VFX.
- **Desert — sandstorms**: quicksand pool (calm) / quicksand per burst with 15%
  tornado instead (storm). Plus `stage_speed_mult = 0.88` on sand.
- **Dead Zone — toxic eruptions + grave hands**: calm ticks are 50/50 poison pool
  (8s, 12 dps, `_dead_pool_damage_tick`) or a **grave hand** (`_grave_hand`): 0.8s
  purple crack telegraph 30–200px from the player, then a skeletal hand bursts up —
  15 dmg and **roots movement for 0.8s** (`player.root_timer`; aiming/firing still
  work). Storm bursts: 35% hands / 65% fast-decaying pools (4–6s). Enemies +40% HP
  and melee enemies **revive once** at 45% HP.

## Artifacts (`ARTIFACTS`, one-time)

Ancient Magnet (240 px pull), Phoenix Heart (revive at 50% + blast), Spirit Familiar
(weighted 3× in the pool), **Thorn Charm** (`player.thorns`: when hit, 20 dmg ×
`sig_dmg_mul` knockback burst in 200 px, 6s CD — see `player._thorns_burst`), Ancient
Scope (20% crit ×2), XP Gem (double XP).

## Status effects & Exploit

`enemy.gd` keeps **separate DoT slots**: `frost_dot`/`frost_dot_timer` (frost weapon)
and `burn_dot`/`burn_timer` (Fire Shells core) — they **stack**, don't overwrite.
Burning enemies are tinted orange, frozen blue, poisoned green. The Exploit card
(+40%) counts *any* of slow / frost / burn / freeze / poison, in both
`projectile._hit_damage` and the katana `_slash_hit`.

## Pacts, run stats & pause build display

- **Pacts** (`pacts` array, toggled on the map-select panel, reset each run): (1)
  enemies +30% HP / +15% dmg → gold ×1.5, (2) storms twice as often → souls ×1.5,
  (3) no heal drops + half level-heal → +20% damage. Effects are applied at
  `_apply_meta_upgrades`, `_on_coin_collected`, `_spawn_boss`, `_hazard_tick`,
  `_spawn_pickup`, `_show_level_up`.
- **Damage stats**: every player damage source calls `game.report_damage(src, amt)`
  (helper `player.report_dmg`, `projectile._report` with its `src` field). The end
  screen shows a per-source breakdown panel (`_show_run_stats`, names in
  `DMG_NAMES`). When adding a new damage source, report it or it won't show up.
- **Pause menu** lists the current build (`_build_summary`): main weapon + core +
  form, secondary weapon levels (★ = evolved), owned artifacts.

## Meta-progression & economy

`META_UPGRADES`: gold buys survival (HP/speed/magnet), souls buy attack
(dmg/fire/crit); cost = `base × (level+1)`. Each purchased level adds +1.5% enemy
HP/damage (`difficulty`), **except magnet** (pure utility, tax-exempt). Full gold
tree ≈ 18k gold (~9 winning runs); full soul tree ≈ 180 souls (~11 runs).

## Audio

Music per map; SFX all run through the settings **SFX slider** (`_set_sfx_vol`).
Synthesized chiptune WAVs in `assets/audio/` (replace by overwriting the same
filename, then run `--import`): `gem` (pitch rises with pickup combo, resets after
0.6s), `coin`, `levelup`, `chest`, `boss`, `extract` (also the win jingle), `hurt`
(player, 0.35s cooldown via `hurt_fx_t`), `ui_click` (menus/cards/shop/pause).
Menu-time players use `PROCESS_MODE_ALWAYS`. Thorn burst reuses `explosion.ogg`.

## Debug panel

`_build_debug_panel` is only built when `OS.is_debug_build()`. Buttons: "Thú" (spawn
a familiar), "Reset NV" (wipes the save — requires a **second click within 3s** to
confirm).

## Conventions & gotchas

- **Bilingual everything**: any new player-facing string goes into `I18N` as a
  `[vietnamese, english]` pair, fetched with `T("key")`; refresh in `_apply_lang()`.
- **Code-built UI**: `_build_*` panels append to `$UI` and set
  `process_mode = PROCESS_MODE_ALWAYS` to survive `get_tree().paused`. Menu skinning
  helpers: `_skin_menu_panel/_skin_menu_card/_skin_menu_button/_style_menu_title`.
- **Keyboard nav**: menus are driven by `levelup_nav.gd` signals through `_ui_nav` /
  `_ui_accept`; buttons use `focus_mode = FOCUS_NONE` to avoid Space double-firing.
- **ESC guard**: `_toggle_pause` must ignore ESC while any full-screen menu
  (level-up, char select, chest, **map select, shop**) is open — unpausing behind a
  menu starts the game with no character.
- **Group/signal coupling**: prefer group lookups and signals over stored references;
  nodes are freed constantly, guard with `is_instance_valid(...)`.
- **AnimatedSprite2D from atlas**: reuse `_make_anim_sprite` (familiar.gd). Don't
  loop one-shot VFX.
- **z_index layering**: child z_index is relative; for glow-behind-sprite rely on
  add-order, not negative z_index.
- **Type inference**: `var x := randf() < t` can fail inference — annotate
  `var x: bool = ...`.
- **.import UIDs**: don't hand-write `uid=` lines; let Godot assign them on import.
- **Assets**: third-party art/audio is CC0 / CC-BY; see `CREDITS.txt` files under
  `assets/characters`, `assets/icons`, `assets/vfx`.

## Key balance values (as of 2026-07)

| Parameter | Value | Location |
|-----------|-------|----------|
| Spawn interval | `maxf(0.35, 1.1 - t*0.015)` | `game.gd _process` |
| Enemy speed caps (melee/runner) | 170 / 230 | `game.gd _spawn_enemy` |
| Boss HP | `220 + t*2.5`; final ×2.0 (DZ ×2.4) | `game.gd _spawn_boss` |
| XP curve | `int(n*1.10)+4`; +1 gem/kill after 210s | `game.gd` |
| Pickup drop rate | 0.8%; heal/magnet/bomb 10/45/45 | `game.gd` |
| Death penalty | keep 25% gold, 50% souls | `game.gd _on_player_died` |
| Souls per boss | mini 2, final 8–12 | `game.gd _spawn_boss` |
| Magma core | 12 dmg/s pool, 3s (×1.6, 4s enhanced) | `game.gd spawn_lava_pool` |
| Soul Burst form | 18 dmg × dmg-mult, 100 px | `game.gd _soulburst` |
| Thorn Charm | 20 dmg × dmg-mult, 200 px, 6s CD | `player.gd _thorns_burst` |
| Storm strike | 90 px, 25 dmg player / 30 enemy | `game.gd _lightning_strike` |
| Familiar nova | 38 dmg, 100 px, 8s charge | `familiar.gd` |
| Meta difficulty tax | +1.5%/level, magnet exempt | `game.gd _apply_meta_upgrades` |
