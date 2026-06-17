# CLAUDE.md

Guidance for working in this repository.

## What this is

A **Vampire Survivors–style** auto-battler built in **Godot 4.6** (Forward Plus). You
pick a character, move with WASD/arrows, and weapons fire automatically at the nearest
enemy. Survive escalating waves, collect XP gems to level up and pick upgrades, kill
bosses for treasure chests, and earn gold that buys permanent upgrades between runs.

The game is **bilingual**: `lang = 0` is Vietnamese (default), `lang = 1` is English.
All player-facing strings live in the `I18N` dictionary in `game.gd` as `[vi, en]`
pairs, read via the `T(key)` helper. **Source-code comments are written in Vietnamese.**

## Running

There is no build script or test suite. Open the project in the Godot 4.6 editor and
run it (`F5`), or run the main scene `scenes/main.tscn` directly. The Godot binary is
not vendored. `.godot/` (the editor's import cache) is gitignored.

Persistent state is stored in Godot's `user://` directory:
- `user://settings.cfg` — selected language
- `user://save.cfg` — accumulated `gold` and permanent upgrade levels

## Architecture — read this first

The scene tree is **deliberately minimal**. `scenes/main.tscn` contains only:

```
Main (Node2D, game.gd)
├── Player (CharacterBody2D, player.gd) — Sprite2D, Camera2D, CollisionShape2D
└── UI (CanvasLayer) — HP/XP bars, labels, level-up panel, character-select panel,
					   settings panel, buttons (built-in nodes only)
```

**Almost every other game object is created in code, not as a `.tscn`.** Enemies,
bosses, projectiles, gems, pickups, crates, decor, and several UI panels (shop, chest,
pause, language row, debug) are instantiated with `Area2D.new()` / `Node2D.new()` /
`Button.new()` and given behavior via `node.set_script(SOME_SCRIPT)`. There are **no
separate scene files for enemies or projectiles** — `scripts/*.gd` are the units of
composition. When adding a new entity, follow this same pattern: `new()` the node,
`set_script()`, set its `var` fields, `add_child()`, then position it.

Objects coordinate through **signals** and **node groups** rather than direct
references:
- Groups: `"enemies"`, `"gems"`, `"crates"`, `"announce"`. Queried with
  `get_tree().get_nodes_in_group(...)` — e.g. weapons find targets this way.
- Signals: enemies emit `died` / `summon` / `tornado` / `quicksand`; gems emit
  `collected`; pickups emit `taken`; crates emit `broke`; player emits `died`.
  `game.gd` wires these up in `_make_enemy()` and the various `_spawn_*` functions.

**Pausing**: menus call `get_tree().paused = true`. Nodes that must keep working while
paused (UI panels, music, the ESC listener) set
`process_mode = Node.PROCESS_MODE_ALWAYS`. Keep this in mind when adding UI.

## Files

| File | Role |
|------|------|
| `scripts/game.gd` (~1560 lines) | **Central controller** on `Main`. Owns time/wave progression, enemy & boss spawning, stage transitions, wave events, the level-up flow, artifacts, meta-progression + gold shop, I18N, music, and all code-built UI panels. Start here. |
| `scripts/player.gd` | `CharacterBody2D`. Movement, auto-aim/auto-fire, all weapons, stats, `take_damage`/`heal`/revive, camera shake, hurt FX. |
| `scripts/enemy.gd` | `Area2D`. Enemy + boss AI. `Kind` = MELEE/RANGER/BOSS; `State` = CHASE/TELEGRAPH/DASH. Elite modifiers, status effects, boss skills, damage numbers. |
| `scripts/projectile.gd` | Player bullets: pierce, AoE, slow/freeze/frost-DoT, knockback, trails. |
| `scripts/enemy_projectile.gd` | Enemy bullets. |
| `scripts/boomerang.gd` | Boomerang weapon (out-and-return, homes back to player). |
| `scripts/tornado.gd` / `scripts/quicksand.gd` | Desert-boss hazards (chasing tornado; slowing sand pools). |
| `scripts/gem.gd` | XP gem with glow + bob + particle VFX; magnet-pull behavior (value 1 normal, 5 from elites). |
| `scripts/pickup.gd` | Floor drops: `heal` / `magnet` / `bomb`. Each kind has rotating glow, inner ring, bob animation, and colour-coded CPUParticles2D. |
| `scripts/crate.gd` | Breakable crate (breaks on contact; drops pickup or gems). |
| `scripts/familiar.gd` | Spirit familiar artifact: orbits player, auto-fires, charges a **Nova** skill every 8 s (see below). |
| `scripts/pause_listener.gd` | Emits `toggled` on ESC (`ui_cancel`); drives the pause menu. |

## Core systems (all in `game.gd` unless noted)

- **Time & spawning** (`_process`): a single `time` accumulator drives everything.
  Spawn interval `maxf(0.22, 0.9 - time * 0.015)` ramps up quickly early. Enemy
  variety unlocks over time: runner `t > 18s`, ranger `t > 28s`, tank `t > 45s`.
- **Stages** (`STAGES`, `_update_stage`): three biomes — Meadow / Desert / Dead Zone.
  Stage 0 lasts `stage_len` (default **90s**), then alternates between stages 1 and 2.
  A stage change swaps the ground tile, decor set, and music, and re-buffs enemies via
  `_apply_stage`. `stage_len` is tunable live via the debug panel.
- **Bosses** (`_spawn_boss`): every `BOSS_INTERVAL` (**45s**), reset to 12s right after
  a stage change. Desert/Dead-Zone have **front-view** themed bosses (`TEX_BOSS_DESERT`/
  `BONE`, composed from Kenney's Monster Builder Pack, `upright = true`) shown ~50% of the
  time; otherwise (and always in Meadow) a **top-down** boss from `TOPDOWN_BOSSES` is used
  (`_apply_topdown_boss`) — a scaled-up, tinted top-down character sprite that rotates like
  the regular enemies. Off-screen bosses get a red direction arrow (`_update_arrows`).
- **Leveling** (`_on_gem_collected` → `_show_level_up` → `_choose`): gems give XP;
  `xp_needed` grows `*1.4 + 2` per level. Each level-up pauses and offers 3 choices from
  `_build_pool()`: stat upgrades (`STAT_UPGRADES`), weapon level-ups / **evolutions**
  (max level `WEAPON_MAX = 4`, then evolve once), or an `ARTIFACT`.
- **Weapons** (`player.gd`): base weapon per character (`WEAPONS`: pistol/smg/shotgun/
  cannon/laser/sniper) plus stackable secondary weapons — orbital swords, grenade,
  chain lightning, poison aura, boomerang, frost — each with levels and an evolved form.
- **Artifacts** (`ARTIFACTS`): one-time passives (magnet, phoenix revive, spirit
  familiar, crit, double-XP). Regen charm grants `player.regen = 0.5` HP/s (no shop
  upgrade for regen). The familiar artifact is weighted 3× in `_build_pool` so it
  appears more often. The familiar (`scripts/familiar.gd`) is an autonomous pet spawned
  via `_spawn_familiar` that orbits the player and auto-fires.
- **Wave events** (`_trigger_event`): periodic ring / flood / frenzy events.
- **Chests** (`_spawn_chest`/`_open_chest`): dropped by bosses; grant 1–3 random pool
  upgrades.
- **Meta-progression** (`META_UPGRADES`, `_*_meta*`, shop): on death,
  `gold = int((kills + boss_count*20 + int(time/5)) * 0.5)`. Spent in the
  character-select shop on permanent upgrades, applied to the player at character pick
  via `_apply_meta_upgrades`. Regen is **not** available as a shop upgrade.

## Tuned balance values (as of latest session)

| Parameter | Value | Location |
|-----------|-------|----------|
| Enemy spawn interval | `maxf(0.22, 0.9 - time*0.015)` | `game.gd _process` |
| Pickup drop rate (enemies) | 0.8% (`randf() < 0.008`) | `game.gd` |
| Heal / magnet / bomb split | 10% / 45% / 45% | `game.gd` |
| Gold multiplier | ×0.5 of raw score | `game.gd` |
| Regen from charm | 0.5 HP/s | `familiar.gd` / `game.gd` |
| +25 Max HP skill weight | 10% chance in pool | `game.gd _build_pool` |
| Bomb explosion radius | 280 px | `game.gd` |
| Familiar nova damage | 38 (×2 on crit) | `familiar.gd` |
| Familiar nova radius | 310 px | `familiar.gd` |
| Familiar nova charge time | 8 s | `familiar.gd` |

## Familiar — Nova skill (`scripts/familiar.gd`)

The familiar charges for `CHARGE_TIME = 8.0` s (visible as a glowing ring that grows
and brightens). On firing:

1. A projectile (`projectile.gd`) is launched toward the nearest enemy at speed 200.
   Its default `Sprite2D` is hidden; an `AnimatedSprite2D` using `assets/vfx/nova_orb.png`
   (12 frames × 96×96, spritesheet from *Super Pixel Effects Gigapack*) is attached and
   tweened from scale 1 → 2.8 over the ball's lifetime.
2. After `ball_life = 1.6` s (or immediately if the projectile is already freed), AOE
   damage is applied to all enemies within `NOVA_RADIUS = 310` px.
3. `_spawn_nova_burst(pos)` plays `assets/vfx/nova_burst.png` (10 frames × 128×128,
   *scifi_warp_001_large_green*) at the explosion position, plus an expanding glow ring.
4. The helper `_make_anim_sprite(tex, fw, fh, frames, fps)` builds a one-shot
   `AnimatedSprite2D` from an atlas spritesheet — reuse it for any new sprite animations.

## UI — HP / XP bars

HP and XP bars in `scenes/main.tscn` use `TextureProgressBar` with
`nine_patch_stretch = true` and `stretch_margin_*` set so the parallelogram edges are
not stretched. Textures live in `assets/ui/`:

| File | Used for |
|------|----------|
| `bar_red.png` | HP bar fill (red gradient parallelogram, 123×48) |
| `bar_bg.png` | HP bar background (dark outline, same shape) |
| `bar_blue.png` | XP bar fill (green gradient) |
| `bar_bg_xp.png` | XP bar background (dark green outline) |

Source frames extracted from *Pixel UI Pack 3* (`06.png`) at 3× scale using Python PIL.

## Input actions (`project.godot`)

`move_left/right/up/down` (WASD **and** arrow keys), `restart` (R, on the game-over
screen), `ui_cancel` (ESC, toggles pause).

## Conventions & gotchas

- **Bilingual everything**: any new player-facing string must be added to `I18N` as a
  `[vietnamese, english]` pair and fetched with `T("key")`. UI text is refreshed in
  `_apply_lang()`.
- **Code-built UI**: panels created in `_build_*` functions append to `$UI` and set
  `process_mode = PROCESS_MODE_ALWAYS` so they survive `get_tree().paused`.
- **Group/signal coupling**: prefer the existing group lookups and signals over holding
  direct node references; nodes are freed with `queue_free()` constantly, so guard with
  `is_instance_valid(...)`.
- **AnimatedSprite2D from atlas**: use `_make_anim_sprite(tex, fw, fh, frames, fps)` in
  `familiar.gd` as a reference pattern — `AtlasTexture` regions across a single row,
  `SpriteFrames` with `loop = false`. Do not set loop on VFX one-shots.
- **z_index layering gotcha**: child nodes use *relative* z_index. Setting `z_index = -1`
  on a child of a z_index=4 node renders it behind ground tiles (ground z=0 baseline).
  For layering siblings (e.g. glow behind sprite), rely on add-order instead of z_index.
- **Type inference**: `var x := randf() < threshold` may fail Godot type inference.
  Use `var x: bool = randf() < threshold` explicitly.
- **.import UIDs**: manually written UIDs are often rejected. Leave the `uid=` line out
  of hand-crafted `.import` files — Godot auto-assigns a valid UID on first import.
- **Debug panel** (`_build_debug_panel`, bottom-left): adjusts `stage_len` by ±10s and
  has a "Thú" button that spawns a familiar for testing. This is dev tooling left in the
  build — remove or gate it before shipping.
- **Assets**: third-party art/audio is CC0 / CC-BY / attribution-required; see the
  `CREDITS.txt` files under `assets/characters`, `assets/icons`, and `assets/vfx`.
