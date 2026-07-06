# Bão Quái

A **Vampire Survivors–style** auto-battler built in **Godot 4.6** (Forward Plus
renderer). Pick a map and a character, move to dodge, and let your weapon fire
automatically at the nearest enemy. Survive a tight **7-minute run** with escalating
boss milestones, collect XP gems to build up your character, then bank Gold and Souls
into permanent upgrades between runs.

The game is **bilingual**: Vietnamese (default) and English, switchable from the
character-select screen and the pause menu.

## Running

There is no build step. Open the project in the **Godot 4.6** editor and press **F5**,
or run the main scene `scenes/main.tscn` directly. The Godot binary is not included in
the repo, and `.godot/` (the editor's import cache) is gitignored, so the first launch
will reimport assets.

Progress is saved automatically to Godot's `user://` directory:

- `user://settings.cfg` — selected language
- `user://save.cfg` — Gold, Souls, permanent upgrade levels, unlocked maps & character

## Controls

| Action | Keys |
|--------|------|
| Move | **WASD** or **arrow keys** |
| Navigate menus / pick cards | **WASD / arrows + Space** (mouse also works) |
| Pause / menu | **Esc** |
| Restart (on the end screen) | **R** |

Aiming and firing are fully automatic — your weapon targets the nearest enemy.

## How a run works

1. **Pick a map**, then **pick a character** (and spend Gold/Souls in the shop).
2. **Survive 7 minutes.** Spawn pressure ramps fast; enemy variety unlocks over time.
3. **Boss milestones**: mini-bosses at **2:00, 4:00 and 5:30**, final boss at **7:00**.
   Killing the final boss clears the map (and unlocks the next one).
4. **Extraction gates**: each mini-boss kill opens a 30s gate. Stand in it for 3s to
   **extract safely and keep 100%** of the Gold and Souls earned this run.
5. **Death penalty**: dying keeps only **25% Gold and 50% Souls** — extract or win to
   keep it all. Risk it or bank it.
6. **Level milestones**: level 10 picks a weapon **Core** (changes how you fight),
   15 enhances it, 20 picks a **Form** (Soul Burst or Shock), 25 is the **Ultimate
   Awakening** — a chase goal for double-XP builds.

## Characters

| Character | Weapon | Style |
|-----------|--------|-------|
| Commando | Shotgun | Mid-range burst, 7-pellet spread |
| Tough Grandpa | Cannon | Slow, wide explosive blasts; tanky |
| Hunter | Sniper | Piercing straight-line shots, keep your distance |
| Ronin *(unlock: clear Desert)* | Katana | Wide melee arc, high risk / high reward |
| Agent *(unlock: clear Dead Zone)* | SMG | Blazing fire rate, fragile |

Each weapon has its own two level-10 Cores (e.g. Shotgun: Fire Shells / Slug Rounds;
Cannon: Black Hole / Magma; Sniper: Armor Pierce / Execute; Katana: Blade Wave /
Berserker; SMG: Incendiary / AP Rounds).

## Maps & environmental hazards

Maps are chosen per run and unlocked in order. Each has its own terrain, music, enemy
buffs **and a movement challenge**:

| Map | Hazard |
|-----|--------|
| **Meadow** | Recurring **thunderstorms** — dodge telegraphed lightning circles (they zap enemies too) |
| **Desert** | Slower movement on sand, roaming **sand tornados**, **quicksand** pools |
| **Dead Zone** | Poison pools, tougher enemies, melee enemies **revive once** |

## Progression systems

- **Secondary weapons** — orbital swords, grenade, chain lightning, poison aura,
  boomerang, frost bolt; level them up and **evolve** a maxed weapon.
- **Stat cards** — damage, cooldown, multishot (adaptive per weapon), pierce/reach,
  speed, max HP, Exploit (+40% vs afflicted), Fortitude (damage reduction).
- **Artifacts** — one-time passives: Ancient Magnet, Phoenix Heart (revive),
  Spirit Familiar (orbiting pet with a nova), **Thorn Charm** (retaliation blast when
  hit), Ancient Scope (crit), XP Gem (double XP).
- **Meta shop** — dual currency: **Gold** (from kills/crates) buys survival stats,
  **Souls** (from bosses only) buy attack stats. Permanent across runs.

## Project layout

```
vampire-survivors/
├── project.godot          # Godot project config + input map
├── scenes/main.tscn       # The only scene: Main + Player + UI
├── scripts/               # All gameplay logic (GDScript)
│   ├── game.gd            # Central controller — spawning, bosses, hazards, UI, meta, I18N
│   ├── player.gd          # Movement, auto-aim/fire, weapons, stats
│   ├── enemy.gd           # Enemy & boss AI, status effects
│   ├── projectile.gd      # Player bullets (pierce, AoE, black hole, DoTs)
│   └── ...                # gem, coin, pickup, crate, familiar, extraction gate, etc.
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
- **Reward/UI SFX** (`gem`, `coin`, `levelup`, `hurt`, `chest`, `boss`, `extract`,
  `ui_click` in `assets/audio/`) — chiptune sounds synthesized in-house; drop-in
  replaceable with e.g. [ChipTone](https://sfbgames.itch.io/chiptone) exports
