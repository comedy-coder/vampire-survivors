# Vampire Survivors (Godot)

A **Vampire Survivors–style** auto-battler built in **Godot 4.6** (Forward Plus
renderer). Pick a character, move to dodge, and let your weapon fire automatically at
the nearest enemy. Survive escalating waves, collect XP gems to level up and pick
upgrades, kill bosses for treasure chests, and earn gold that buys permanent upgrades
between runs.

The game is **bilingual**: Vietnamese (default) and English, switchable from the
settings panel.

## Running

There is no build step. Open the project in the **Godot 4.6** editor and press **F5**,
or run the main scene `scenes/main.tscn` directly. The Godot binary is not included in
the repo, and `.godot/` (the editor's import cache) is gitignored, so the first launch
will reimport assets.

Progress is saved automatically to Godot's `user://` directory:

- `user://settings.cfg` — selected language
- `user://save.cfg` — accumulated gold and permanent (meta) upgrade levels

## Controls

| Action | Keys |
|--------|------|
| Move | **WASD** or **arrow keys** |
| Pause / menu | **Esc** |
| Restart (on the game-over screen) | **R** |

Aiming and firing are fully automatic — your weapon targets the nearest enemy. Level-up
choices, the shop, and menus are mouse-driven.

## How a run works

1. **Pick a character** from the select screen (and spend gold on permanent upgrades in
   the shop).
2. **Move to survive.** Weapons fire on their own; enemy variety and difficulty scale
   with elapsed time.
3. **Collect XP gems** dropped by kills. Each level-up pauses the game and offers 3
   choices: a stat boost, a weapon level-up / evolution, or an artifact.
4. **Cross biomes.** The world cycles through three stages, each swapping the terrain,
   décor, music, and enemy buffs.
5. **Beat bosses** (roughly every 45s) to drop **treasure chests** that grant 1–3 random
   upgrades.
6. **Die and bank gold.** Gold earned from a run (`kills + bosses×20 + time/5`) is spent
   on permanent meta-upgrades that carry into future runs.

## Characters

Six characters, each defined by a unique base weapon and stat profile:

| Character | Weapon | Style |
|-----------|--------|-------|
| Commoner | Pistol | Balanced all around |
| Warrior Woman | SMG | Blazing fire rate, fragile |
| Commando | Shotgun | 5-pellet close-range spread |
| Tough Grandpa | Cannon | Explosive AoE shells, slow |
| Survivor | Laser | Piercing beam shots |
| Hunter | Sniper | Huge damage, ultra-fast bullets |

## Progression systems

- **Weapons** — Each character starts with a base weapon. Through level-ups you can add
  **secondary weapons** (orbital swords, grenade, chain lightning, poison aura,
  boomerang, frost), level them up, and **evolve** a maxed weapon into a stronger form.
- **Stat upgrades** — Max HP, Damage, Fire rate, Move speed, HP regen, Magnet range,
  Crit chance.
- **Artifacts** — One-time passives: Ancient Magnet (triple pickup range), Phoenix Heart
  (revive once with a knockback blast), Spirit Familiar (an auto-firing pet that orbits
  you), Regen Charm, Ancient Scope (crit chance), XP Gem (double XP).
- **Meta-progression** — Spend banked gold in the character-select shop on permanent
  upgrades (HP, damage, fire rate, move speed, regen, and more) that apply to every
  future run.

## Stages & bosses

Three biomes cycle through a run — **Meadow**, **Desert**, and **Dead Zone** — each with
its own terrain, décor, music, and enemy buffs. Bosses appear on a timer and include
themed front-view bosses (Zombie Lord, Bone boss) and scaled-up top-down bosses (Robot
Fortress, Shadow Assassin, Warlord), each with their own skills. Off-screen bosses are
marked with a direction arrow.

## Project layout

```
vampire-survivors/
├── project.godot          # Godot project config + input map
├── scenes/main.tscn       # The only scene: Main + Player + UI
├── scripts/               # All gameplay logic (GDScript)
│   ├── game.gd            # Central controller — spawning, stages, UI, meta, I18N
│   ├── player.gd          # Movement, auto-aim/fire, weapons, stats
│   ├── enemy.gd           # Enemy & boss AI
│   ├── projectile.gd      # Player bullets
│   └── ...                # gem, pickup, crate, familiar, tornado, etc.
├── assets/                # Art, audio, icons, décor (+ CREDITS.txt files)
└── CLAUDE.md              # Detailed architecture notes for developers
```

Most game objects (enemies, projectiles, gems, most UI panels) are **created in code**
rather than as separate scene files — see `CLAUDE.md` for the full architecture, the
signal/group conventions, and developer gotchas.

## Credits

Third-party assets are used under their respective licenses (see the `CREDITS.txt` files
under `assets/characters`, `assets/icons`, and `assets/vfx`):

- **Character & boss sprites** — Kenney's *Topdown Shooter* and *Monster Builder Pack*
  (CC0)
- **UI / weapon / elite icons** — [game-icons.net](https://game-icons.net) by Lorc,
  Delapouite, and Zeromancer (CC BY 3.0); elite badges from Akami Assets' *Buff & Debuff
  Icon Pack* (CC0)
- **VFX** — *Super Pixel Effects Gigapack* by Will Tice / unTied Games (free with
  attribution)
