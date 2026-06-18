extends Node2D

const ENEMY := preload("res://scripts/enemy.gd")
const GEM := preload("res://scripts/gem.gd")
const COIN := preload("res://scripts/coin.gd")
const EXTRACTION_GATE := preload("res://scripts/extraction_gate.gd")
const TORNADO := preload("res://scripts/tornado.gd")
const QUICKSAND := preload("res://scripts/quicksand.gd")
const PICKUP := preload("res://scripts/pickup.gd")
const CRATE := preload("res://scripts/crate.gd")
const FAMILIAR := preload("res://scripts/familiar.gd")

const ICON_PICK_HEAL := preload("res://assets/icons/up_hp.svg")
const ICON_PICK_MAGNET := preload("res://assets/icons/art_magnet.svg")
const ICON_PICK_BOMB := preload("res://assets/icons/w_grenade.svg")

const TEX_FOG_CLOUD := preload("res://assets/vfx/fog_cloud.png")
const TEX_FOG_PUFF  := preload("res://assets/vfx/fog_puff.png")
const TEX_FOG_TILE  := preload("res://assets/vfx/fog_tile.png")
const TEX_ZOMBIE := preload("res://assets/characters/zombie.png")
const TEX_HITMAN := preload("res://assets/characters/hitman.png")
const TEX_ROBOT := preload("res://assets/characters/robot.png")
const TEX_GRASS := preload("res://assets/tiles/grass_01.png")
const MUSIC_MENU   := preload("res://assets/audio/music_menu.wav")
const MUSIC_GAME   := preload("res://assets/audio/music_game.wav")
const MUSIC_DESERT := preload("res://assets/audio/music_desert.mp3")
const MUSIC_DEAD   := preload("res://assets/audio/music_dead.mp3")
const SND_DIE := preload("res://assets/audio/enemy_die.ogg")
const FONT_ANNOUNCE := preload("res://assets/fonts/Baloo2.ttf")
const CIRCLE := preload("res://assets/circle.svg")
const TEX_UI_PANEL := preload("res://assets/ui/ui_panel.png")
const TEX_UI_FRAME := preload("res://assets/ui/ui_frame.png")
const TEX_EXPLOSION := preload("res://assets/vfx/explosion_sheet.png")
const TEX_CHEST := preload("res://assets/decor/chest.png")
const ICON_CHEST := preload("res://assets/icons/art_chest.svg")
const TEX_BOSS_DESERT := preload("res://assets/characters/boss_desert.png")
const TEX_BOSS_BONE   := preload("res://assets/characters/boss_bone.png")
const TEX_SOLDIER := preload("res://assets/characters/player_soldier.png")

# Boss top-down: sprite quái nhìn từ trên xuống, phóng to, xoay theo hướng như quái thường
const TOPDOWN_BOSSES := [
	{"tex": TEX_ZOMBIE,  "name": ["ZOMBIE CHÚA!", "ZOMBIE LORD!"],          "tint": Color(1.0, 0.5, 0.5),  "speed": 72.0, "bullet": 0.0,  "skills": ["dash", "dash", "summon"]},
	{"tex": TEX_ROBOT,   "name": ["ROBOT PHÁO ĐÀI!", "ROBOT FORTRESS!"],    "tint": Color(0.8, 0.6, 1.0),  "speed": 56.0, "bullet": 10.0, "skills": ["burst", "burst", "summon"]},
	{"tex": TEX_HITMAN,  "name": ["SÁT THỦ BÓNG ĐÊM!", "SHADOW ASSASSIN!"], "tint": Color(0.55, 0.7, 1.0), "speed": 96.0, "bullet": 9.0,  "skills": ["spiral", "dash", "burst"]},
	{"tex": TEX_SOLDIER, "name": ["ĐẠI TƯỚNG!", "WARLORD!"],                "tint": Color(1.0, 0.72, 0.4), "speed": 60.0, "bullet": 12.0, "skills": ["burst", "summon", "burst"], "meadow_only": true},
]

const I18N := {
	"levelup_title": ["LEVEL UP! Chọn nâng cấp  (WASD + Space)", "LEVEL UP! Choose an upgrade  (WASD + Space)"],
	"sig_core_title": ["CẤP 5 — CHỌN LÕI (đổi lối đánh)", "LV 5 — CHOOSE CORE"],
	"sig_enhance_title": ["CẤP 10 — CƯỜNG HÓA LÕI", "LV 10 — CORE ENHANCED"],
	"sig_form_title": ["CẤP 15 — CHỌN HÌNH THÁI", "LV 15 — CHOOSE FORM"],
	"sig_ultimate_title": ["CẤP 20 — THỨC TỈNH TỐI THƯỢNG", "LV 20 — ULTIMATE AWAKENING"],
	"sig_enhance_label": ["⚡ CƯỜNG HÓA LÕI\nLõi của bạn mạnh hơn nữa — Nhận!", "⚡ CORE ENHANCED\nYour core grows stronger — Take!"],
	"sig_ultimate_label": ["☆ THỨC TỈNH!\nLõi + Hình thái tối đa & dọn màn — Nhận!", "☆ AWAKENING!\nCore + Form maxed & screen clear — Take!"],
	"char_title": ["CHỌN NHÂN VẬT  (WASD + Space)", "CHOOSE YOUR CHARACTER  (WASD + Space)"],
	"sound_title": ["ÂM THANH", "SOUND"],
	"music": ["Nhạc nền", "Music"],
	"sfx": ["Tiếng súng", "Sound FX"],
	"close": ["Đóng", "Close"],
	"chest_title": ["RƯƠNG BÁU VẬT!", "TREASURE CHEST!"],
	"chest_take": ["Nhận!  (Space)", "Take!  (Space)"],
	"pause_title": ["TẠM DỪNG", "PAUSED"],
	"resume": ["Tiếp tục", "Resume"],
	"reselect": ["Chọn lại nhân vật", "Change character"],
	"lang_label": ["Ngôn ngữ:", "Language:"],
	"boss_announce": ["BOSS XUẤT HIỆN!", "BOSS INCOMING!"],
	"map_title": ["CHỌN BẢN ĐỒ", "CHOOSE A MAP"],
	"map_locked": ["🔒 Chưa mở khóa", "🔒 Locked"],
	"miniboss_announce": ["MINI-BOSS!", "MINI-BOSS!"],
	"final_announce": ["BOSS CUỐI CÙNG!", "FINAL BOSS!"],
	"gate_announce": ["CỔNG THOÁT HIỆN RA! (30s)", "EXTRACTION GATE! (30s)"],
	"gate_closed": ["Cổng thoát đã đóng", "Extraction gate closed"],
	"gate_label": ["RÚT LUI", "EXTRACT"],
	"extract_fmt": ["RÚT LUI AN TOÀN!\nSống sót %s — %d kills\nNhấn R để về menu",
		"EXTRACTED SAFELY!\nSurvived %s — %d kills\nPress R for menu"],
	"win_fmt": ["CHIẾN THẮNG!\nPhá đảo %s — %d kills\nNhấn R để về menu",
		"VICTORY!\nCleared %s — %d kills\nPress R for menu"],
	"win_unlock": ["\nĐã mở khóa: %s", "\nUnlocked: %s"],
	"boss_desert": ["HUNG THẦN SA MẠC!", "DESERT FIEND!"],
	"boss_dead":  ["CHÚA TỂ XƯƠNG!", "BONE LORD!"],
	"core_frenzy_on":  ["⚡ CUỒNG NỘ! Mọi chỉ số ×2!", "⚡ FRENZY! All stats ×2!"],
	"core_frenzy_off": ["Cuồng nộ tan dần...", "Frenzy fades..."],
	"wx_fog": ["🌫 SƯƠNG MÙ PHỦ KHẮP!", "🌫 FOG ROLLS IN!"],
	"wx_fog_end": ["Sương mù tan dần...", "The fog clears..."],
	"wx_rain": ["🌧 MƯA LỚN! Vùng mưa làm chậm di chuyển", "🌧 HEAVY RAIN! Rain zone slows movement"],
	"wx_rain_end": ["Mưa tạnh.", "Rain stopped."],
	"wx_rain_enter": ["Mưa — chậm lại!", "Rain — slowed!"],
	"wx_rain_exit": ["Thoát khỏi vùng mưa", "Left the rain"],
	"ev_ring": ["BẦY QUÁI VÂY QUANH!", "SURROUNDED!"],
	"ev_flood": ["QUÁI TRÀN TỚI!", "MONSTER FLOOD!"],
	"ev_frenzy": ["PHÚT CUỒNG NỘ!", "FRENZY!"],
	"hp_fmt": ["HP: %d / %d", "HP: %d / %d"],
	"level_fmt": ["Level %d  (XP %d/%d)", "Level %d  (XP %d/%d)"],
	"kills_fmt": ["Kills: %d", "Kills: %d"],
	"char_stats": ["HP %d • Tốc %d • DMG %.1f", "HP %d • SPD %d • DMG %.1f"],
	"gameover_fmt": ["GAME OVER\nSống sót: %02d:%02d — %d kills\nNhấn R để chơi lại",
		"GAME OVER\nSurvived: %02d:%02d — %d kills\nPress R to restart"],
	"weapon_lv": ["%s (Cấp %d → %d)", "%s (Lv %d → %d)"],
	"artifact_fmt": ["CỔ VẬT: %s\n%s", "ARTIFACT: %s\n%s"],
	"stage_fmt": ["VÙNG MỚI: %s", "NEW AREA: %s"],
	"shop_btn": ["🛒 Nâng cấp (💰%d  🔮%d)", "🛒 Upgrades (💰%d  🔮%d)"],
	"shop_title": ["NÂNG CẤP VĨNH VIỄN", "PERMANENT UPGRADES"],
	"shop_gold": ["💰 Vàng: %d", "💰 Gold: %d"],
	"shop_balance": ["💰 Vàng: %d      🔮 Linh Hồn: %d", "💰 Gold: %d      🔮 Souls: %d"],
	"shop_close": ["← Quay lại", "← Back"],
	"shop_sec_gold": ["— SINH TỒN (Vàng) —", "— SURVIVAL (Gold) —"],
	"shop_sec_soul": ["— TẤN CÔNG (Linh Hồn) —", "— ATTACK (Souls) —"],
	"shop_buy": ["%s  (Cấp %d/%d)\n%s — Giá %d %s", "%s  (Lv %d/%d)\n%s — Cost %d %s"],
	"shop_max": ["%s  (TỐI ĐA)\n%s", "%s  (MAX)\n%s"],
	"reward_fmt": ["\nVàng: +%d 💰     Linh Hồn: +%d 🔮", "\nGold: +%d 💰     Souls: +%d 🔮"],
	"death_penalty": ["\n(Chết: chỉ giữ 50% Vàng — Linh Hồn không mất)", "\n(Died: kept 50% gold — souls safe)"],
}

# Phase 4: tinh gọn còn 4 nhân vật chuyên biệt. "locked" = cần mở khóa (Kiếm khách).
const CHARACTERS := [
	{
		"tex": preload("res://assets/characters/player_soldier.png"),
		"name": ["Lính đặc nhiệm", "Commando"],
		"desc": ["Shotgun — cận chiến tầm trung, dồn sát thương", "Shotgun — mid-range burst damage"],
		"weapon_short": ["Shotgun • cận chiến", "Shotgun • close range"],
		"hp": 110.0, "speed": 205.0, "fire": 1.15, "dmg": 2.4, "count": 1, "pierce": 0,
		"weapon": "shotgun",
	},
	{
		"tex": preload("res://assets/characters/player_old.png"),
		"name": ["Ông già gân", "Tough Grandpa"],
		"desc": ["Pháo — bắn chậm, nổ lan rộng", "Cannon — slow, wide explosive blasts"],
		"weapon_short": ["Pháo • nổ diện rộng", "Cannon • wide blast"],
		"hp": 165.0, "speed": 170.0, "fire": 0.8, "dmg": 6.5, "count": 1, "pierce": 0,
		"weapon": "cannon",
	},
	{
		"tex": preload("res://assets/characters/player_brown.png"),
		"name": ["Thợ săn", "Hunter"],
		"desc": ["Bắn tỉa — đường thẳng, giữ khoảng cách", "Sniper — straight-line, keep distance"],
		"weapon_short": ["Sniper • xuyên giáp", "Sniper • armor pierce"],
		"hp": 90.0, "speed": 230.0, "fire": 0.95, "dmg": 5.5, "count": 1, "pierce": 1,
		"weapon": "sniper",
	},
	{
		"tex": preload("res://assets/characters/player_woman.png"),
		"name": ["Kiếm khách", "Ronin"],
		"desc": ["Katana — chém góc rộng cận chiến, mạo hiểm cao", "Katana — wide melee arc, high risk"],
		"weapon_short": ["Katana • cận chiến rủi ro", "Katana • risky melee"],
		"hp": 115.0, "speed": 255.0, "fire": 1.7, "dmg": 3.6, "count": 1, "pierce": 0,
		"weapon": "katana", "locked": true,
	},
]

const BOSS_INTERVAL := 45.0  # (không còn dùng cho nhịp boss; giữ để tương thích)

# --- Phase 1: nhịp độ 15 phút/ván, boss theo mốc thời gian ---
const RUN_LEN := 900.0              # 15 phút mỗi ván
const MINIBOSS_TIMES := [120.0, 240.0]  # Mini-boss ở phút 2 và 4
const FINAL_TIME := 420.0           # Final boss ở phút 7

const DECOR := [
	{"tex": preload("res://assets/decor/grass_tuft.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/grass_tuft.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/grass_tuft.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/plant.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/plant.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/bush_green.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/bush_small.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/rock_1.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/rock_2.png"), "s": [0.6, 1.0]},
	{"tex": preload("res://assets/decor/tree.png"), "s": [1.5, 2.1]},
]
const DECOR_DESERT := [
	# Đá
	{"tex": preload("res://assets/decor/desert_stone1.png"),   "s": [0.22, 0.42]},
	{"tex": preload("res://assets/decor/desert_stone2.png"),   "s": [0.18, 0.32]},
	{"tex": preload("res://assets/decor/desert_rock_sand.png"),"s": [0.08, 0.16]},
	# Xương rồng
	{"tex": preload("res://assets/decor/desert_cactus1.png"),  "s": [0.10, 0.22], "no_rot": true},
	{"tex": preload("res://assets/decor/desert_cactus2.png"),  "s": [0.11, 0.24], "no_rot": true},
	{"tex": preload("res://assets/decor/desert_cactus3.png"),  "s": [0.25, 0.50], "no_rot": true},
	{"tex": preload("res://assets/decor/desert_cactus4.png"),  "s": [0.25, 0.50], "no_rot": true},
	{"tex": preload("res://assets/decor/desert_melon.png"),    "s": [0.30, 0.55], "no_rot": true},
	# Cây — hiếm
	{"tex": preload("res://assets/decor/desert_palm1.png"),    "s": [0.10, 0.28], "no_rot": true, "chance": 0.30},
	{"tex": preload("res://assets/decor/desert_palm2.png"),    "s": [0.09, 0.26], "no_rot": true, "chance": 0.30},
	{"tex": preload("res://assets/decor/desert_tree_bush.png"),"s": [0.15, 0.35], "no_rot": true, "chance": 0.35},
	{"tex": preload("res://assets/decor/desert_baobab.png"),   "s": [0.10, 0.22], "no_rot": true, "chance": 0.25},
	{"tex": preload("res://assets/decor/desert_deadtree.png"), "s": [0.12, 0.26], "no_rot": true, "chance": 0.25},
	# Đặc biệt — hiếm
	{"tex": preload("res://assets/decor/desert_lake.png"),     "s": [0.18, 0.32], "no_rot": true, "flat": true, "chance": 0.04},
	{"tex": preload("res://assets/decor/desert_pyramid.png"),  "s": [0.20, 0.32], "no_rot": true, "chance": 0.008},
]
const DECOR_DARK := [
	# Đá
	{"tex": preload("res://assets/decor/undead_rock1.png"), "s": [0.5, 0.9]},
	{"tex": preload("res://assets/decor/undead_rock2.png"), "s": [0.5, 0.9]},
	{"tex": preload("res://assets/decor/undead_rock3.png"), "s": [0.5, 1.0]},
	# Xương
	{"tex": preload("res://assets/decor/undead_bones.png"),  "s": [0.8, 1.5]},
	{"tex": preload("res://assets/decor/undead_bones2.png"), "s": [0.8, 1.5]},
	{"tex": preload("res://assets/decor/undead_bones3.png"), "s": [0.8, 1.5]},
	# Cây xanh
	{"tex": preload("res://assets/decor/undead_plant_green1.png"), "s": [0.5, 0.9]},
	{"tex": preload("res://assets/decor/undead_plant_green2.png"), "s": [0.5, 0.9]},
	{"tex": preload("res://assets/decor/undead_plant_green3.png"), "s": [0.5, 0.9]},
	# Cây khô
	{"tex": preload("res://assets/decor/undead_dry_plant.png"),  "s": [0.45, 0.75], "no_rot": true},
	{"tex": preload("res://assets/decor/undead_dry_plant2.png"), "s": [0.5,  0.9],  "no_rot": true},
	# Cánh tay chết
	{"tex": preload("res://assets/decor/undead_dead_arm1.png"), "s": [0.5, 0.9]},
	{"tex": preload("res://assets/decor/undead_dead_arm2.png"), "s": [0.5, 0.9]},
	{"tex": preload("res://assets/decor/undead_dead_arm3.png"), "s": [0.5, 0.9]},
	# Mộ
	{"tex": preload("res://assets/decor/undead_grave1.png"), "s": [1.0, 1.8], "no_rot": true},
	{"tex": preload("res://assets/decor/undead_grave2.png"), "s": [1.0, 1.8], "no_rot": true},
	# Cây chết
	{"tex": preload("res://assets/decor/undead_dead_tree.png"), "s": [0.6, 1.0], "no_rot": true},
	{"tex": preload("res://assets/decor/undead_tree.png"),      "s": [0.55, 0.9], "no_rot": true},
	# Cây đổ
	{"tex": preload("res://assets/decor/undead_broken_tree.png"), "s": [0.4, 0.7], "flat": true},
	# Gai
	{"tex": preload("res://assets/decor/undead_thorn.png"), "s": [0.5, 0.85], "no_rot": true},
	# Hiếm — mặt sọ
	{"tex": preload("res://assets/decor/undead_skull_face1.png"), "s": [0.6, 1.0], "no_rot": true, "chance": 0.30},
	{"tex": preload("res://assets/decor/undead_skull_face2.png"), "s": [0.6, 1.0], "no_rot": true, "chance": 0.30},
	{"tex": preload("res://assets/decor/undead_skull_face3.png"), "s": [0.6, 1.0], "no_rot": true, "chance": 0.30},
	# Hiếm — đổ nát & đống sọ
	{"tex": preload("res://assets/decor/undead_ruin.png"),    "s": [0.6, 1.0], "no_rot": true, "chance": 0.25},
	{"tex": preload("res://assets/decor/undead_skulls.png"),  "s": [0.5, 0.8], "no_rot": true, "chance": 0.15},
	{"tex": preload("res://assets/decor/undead_skulls2.png"), "s": [0.5, 0.8], "no_rot": true, "chance": 0.15},
	{"tex": preload("res://assets/decor/undead_skulls3.png"), "s": [0.5, 0.8], "no_rot": true, "chance": 0.15},
]
const DECOR_CELL := 220.0

var stage_len := 90.0

const STAGES := [
	{
		"name": ["Đồng cỏ", "Meadow"],
		"tile": preload("res://assets/tiles/grass_01.png"),
		"tile_mod": Color.WHITE,
		"decor": DECOR,
		"decor_mod": Color.WHITE,
	},
	{
		"name": ["Sa mạc", "Desert"],
		"tile": preload("res://assets/tiles/desert_craftpix.png"),
		"tile_mod": Color.WHITE,
		"decor": DECOR_DESERT,
		"decor_mod": Color.WHITE,
	},
	{
		"name": ["Vùng đất chết", "Dead Zone"],
		"tile": preload("res://assets/tiles/undead_ground.png"),
		"tile_mod": Color.WHITE,
		"decor": DECOR_DARK,
		"decor_mod": Color(0.65, 0.6, 0.75),
	},
]

const WEAPON_MAX := 4

# Thẻ Thích Ứng: tự nhận diện vũ khí (súng / nổ / cận chiến) để cộng chỉ số phù hợp.
const STAT_UPGRADES := [
	{"label": ["Sức Mạnh Giao Tranh: +20% sát thương", "Combat Power: +20% damage"], "fn": "_up_damage", "icon": preload("res://assets/icons/up_damage.svg")},
	{"label": ["Nhịp Độ Tử Thần: -15% hồi đòn", "Deadly Tempo: -15% cooldown"], "fn": "_up_fire_rate", "icon": preload("res://assets/icons/up_fire_rate.svg")},
	{"label": ["Nhân Bản / Liên Kích: +1 đạn (Kiếm: chém bồi)", "Multishot / Combo: +1 shot (Katana: combo)"], "fn": "_up_projectile", "icon": preload("res://assets/icons/up_projectile.svg")},
	{"label": ["Xuyên Thấu / Khuếch Đại: +1 xuyên (Nổ/Kiếm: +15% tầm)", "Pierce / Amplify: +1 pierce (AoE/Melee: +15% reach)"], "fn": "_up_pierce", "icon": preload("res://assets/icons/up_pierce.svg")},
	{"label": ["+25 Tốc độ chạy", "+25 Move speed"], "fn": "_up_speed", "icon": preload("res://assets/icons/up_speed.svg")},
	{"label": ["+25 Máu tối đa (hồi đầy)", "+25 Max HP (full heal)"], "fn": "_up_max_hp", "icon": preload("res://assets/icons/up_hp.svg")},
	{"label": ["Khai Thác Điểm Yếu: +40% dmg lên quái dính hiệu ứng", "Exploit: +40% dmg to afflicted enemies"], "fn": "_up_exploit", "icon": preload("res://assets/icons/up_exploit.svg")},
	{"label": ["Kiên Cường: -20% sát thương nhận", "Fortitude: -20% damage taken"], "fn": "_up_armor", "icon": preload("res://assets/icons/up_hp.svg")},
	{"label": ["Sức Mạnh Tối Thượng: +20% sát thương vĩnh viễn", "Brute Force: +20% damage permanently"], "fn": "_up_dmg_boost", "icon": preload("res://assets/icons/up_chainreact.svg")},
]

const ICON_ORBITAL := preload("res://assets/icons/w_orbital.svg")
const ICON_GRENADE := preload("res://assets/icons/w_grenade.svg")
const ICON_LIGHTNING := preload("res://assets/icons/w_lightning.svg")
const ICON_POISON := preload("res://assets/icons/w_poison.svg")
const ICON_BOOMERANG := preload("res://assets/icons/w_boomerang.svg")
const ICON_FROST := preload("res://assets/icons/w_frost.svg")

const ARTIFACTS := [
	{"name": ["Nam châm cổ", "Ancient Magnet"], "desc": ["Hút gem từ xa gấp 3 lần", "Triple gem pickup range"], "fn": "_art_magnet", "icon": preload("res://assets/icons/art_magnet.svg")},
	{"name": ["Tim phượng hoàng", "Phoenix Heart"], "desc": ["Hồi sinh 1 lần với nửa máu, nổ đẩy lùi quái", "Revive once at half HP with a knockback blast"], "fn": "_art_phoenix", "icon": preload("res://assets/icons/art_phoenix.svg")},
	{"name": ["Linh thú bay", "Spirit Familiar"], "desc": ["Triệu hồi linh thú bay quanh người, tự bắn quái gần nhất", "Summon a familiar that orbits you and auto-fires at the nearest enemy"], "fn": "_art_familiar", "icon": preload("res://assets/icons/art_familiar.svg")},
	{"name": ["Bùa tái sinh", "Regen Charm"], "desc": ["Hồi 0.5 máu mỗi giây", "Heal 0.5 HP per second"], "fn": "_art_regen", "icon": preload("res://assets/icons/art_regen.svg")},
	{"name": ["Kính ngắm cổ", "Ancient Scope"], "desc": ["20% đạn chí mạng, sát thương x2", "20% crit chance for x2 damage"], "fn": "_art_crit", "icon": preload("res://assets/icons/art_crit.svg")},
	{"name": ["Ngọc kinh nghiệm", "XP Gem"], "desc": ["Mỗi gem cho gấp đôi XP", "Gems give double XP"], "fn": "_art_xp", "icon": preload("res://assets/icons/art_xp.svg")},
]

# Nâng cấp vĩnh viễn — mua bằng vàng tích lũy qua các ván, cộng dồn vào nhân vật khi bắt đầu
# cur = "gold" (Vàng — chỉ số Sinh tồn) hoặc "soul" (Mảnh Linh Hồn — chỉ số Tấn công)
# Giá Vàng đã tăng ~7x do thời lượng game lên 15 phút; giá Linh Hồn nhỏ vì hiếm.
const META_UPGRADES := [
	{"id": "hp",     "cur": "gold", "name": ["Máu tối đa", "Max HP"],         "prop": "max_hp",            "amount": 20.0, "unit": "+20 HP",   "max": 8, "base": 280},
	{"id": "speed",  "cur": "gold", "name": ["Tốc độ chạy", "Move speed"],     "prop": "speed",             "amount": 12.0, "unit": "+12",      "max": 6, "base": 280},
	{"id": "magnet", "cur": "gold", "name": ["Tầm hút gem", "Magnet range"],   "prop": "magnet_range",      "amount": 35.0, "unit": "+35",      "max": 4, "base": 200},
	{"id": "dmg",    "cur": "soul", "name": ["Sát thương", "Damage"],          "prop": "projectile_damage", "amount": 0.4,  "unit": "+0.4 DMG", "max": 8, "base": 2},
	{"id": "fire",   "cur": "soul", "name": ["Tốc độ bắn", "Fire rate"],       "prop": "fire_rate",         "amount": 0.15, "unit": "+0.15",    "max": 6, "base": 3},
	{"id": "crit",   "cur": "soul", "name": ["Tỉ lệ chí mạng", "Crit chance"], "prop": "crit_chance",       "amount": 0.03, "unit": "+3%",      "max": 5, "base": 3},
]

# --- Phase 4b: Nâng cấp Độc bản ---
# LÕI (cấp 5): riêng theo vũ khí, đổi hẳn lối đánh. HÌNH THÁI (cấp 15): chung.
const SIG_CORES := {
	"shotgun": [
		{"id": "burn",   "name": ["LÕI: Đạn Lửa", "CORE: Fire Shells"],   "desc": ["Đạn gây bỏng (sát thương theo thời gian)", "Pellets ignite enemies (burn DoT)"],   "icon": preload("res://assets/icons/core_fire.svg")},
		{"id": "pierce", "name": ["LÕI: Đạn Xuyên", "CORE: Slug Rounds"], "desc": ["Đạn xuyên +3 mục tiêu & mạnh hơn", "Pierce +3 and stronger"],                      "icon": preload("res://assets/icons/core_pierce.svg")},
	],
	"cannon": [
		{"id": "aoe",   "name": ["LÕI: Đại Pháo", "CORE: Heavy Shells"],     "desc": ["Bán kính nổ lớn hơn nhiều", "Much bigger blast radius"],          "icon": preload("res://assets/icons/core_aoe.svg")},
		{"id": "frenzy", "name": ["LÕI: CUỒNG NỘ", "CORE: FRENZY"], "desc": ["Mỗi 30s: 6 giây tất cả chỉ số ×2", "Every 30s: 6 sec all stats ×2"], "icon": preload("res://assets/icons/core_chain.svg")},
	],
	"sniper": [
		{"id": "pierce",    "name": ["LÕI: Xuyên Giáp", "CORE: Armor Pierce"],    "desc": ["Xuyên +3 mục tiêu, sát thương lớn", "Pierce +3, big damage"],              "icon": preload("res://assets/icons/core_pierce.svg")},
		{"id": "explosive", "name": ["LÕI: Đạn Nổ", "CORE: Explosive Rounds"],   "desc": ["Đạn bắn tỉa nổ diện rộng khi trúng", "Sniper rounds explode on hit"],       "icon": preload("res://assets/icons/core_explosive.svg")},
	],
	"katana": [
		{"id": "wave",      "name": ["LÕI: Kiếm Khí", "CORE: Blade Wave"], "desc": ["Mỗi nhát chém phóng làn kiếm khí bay xa", "Each slash fires a flying blade wave"], "icon": preload("res://assets/icons/core_wave.svg")},
		{"id": "lifesteal", "name": ["LÕI: Hút Máu", "CORE: Lifesteal"],   "desc": ["Hồi máu mỗi đòn chém trúng", "Heal on each slash hit"],                           "icon": preload("res://assets/icons/core_lifesteal.svg")},
	],
}
const SIG_FORMS := [
	{"id": "lifedrain",    "name": ["HÌNH THÁI: Hút Hồn", "FORM: Soul Drain"],   "desc": ["Mỗi lần giết quái hồi 0.5 HP", "Killing enemies restores 0.5 HP"], "icon": preload("res://assets/icons/form_explode.svg")},
	{"id": "shock",        "name": ["HÌNH THÁI: Tê Liệt", "FORM: Shock"],        "desc": ["Đòn đánh làm chậm quái trúng", "Hits slow enemies"],        "icon": preload("res://assets/icons/form_shock.svg")},
]

var time := 0.0
var kills := 0
var boss_count := 0
var xp := 0
var level := 1
var xp_needed := 5
var spawn_timer := 0.0
var boss_timer := BOSS_INTERVAL
var game_over := false
var choosing := false
var pending: Array = []
var card_frames: Array = []  # khung viền fantasy cho 3 thẻ chọn nâng cấp
var _sel := 0  # thẻ nâng cấp đang được chọn bằng bàn phím (0..2)
var _char_sel := 0  # nhân vật đang được chọn bằng bàn phím (0..5, lưới 2 cột)
var _map_sel := 0  # map đang được chọn bằng bàn phím (0..2)
var _card_count := 3  # số thẻ đang hiện ở màn lên cấp (1..3)
var chosen_core := ""  # id Lõi đã chọn ở cấp 5 (Phase 4b)
var _frenzy_cd := 0.0          # đếm ngược đến lần cuồng nộ tiếp theo
var _frenzy_dur := 0.0         # thời gian còn lại của đợt cuồng nộ
var _frenzy_on := false        # đang trong trạng thái cuồng nộ
var _frenzy_backup := {}       # lưu chỉ số gốc để khôi phục sau cuồng nộ
var chosen_form := ""  # id Hình thái đã chọn ở cấp 15
var _kill_blast_budget := 0  # giới hạn số vụ nổ "Nổ Chùm" mỗi khung hình
# --- Phase 1: chọn map + mở khóa + nhịp boss ---
var selected_stage := 0     # map đã chọn cho ván hiện tại (cố định cả ván)
var unlocked_maps := 1      # số map đã mở (1=Đồng cỏ, 2=+Sa mạc, 3=+Đất chết)
var ronin_unlocked := false # mở khóa Kiếm khách (dùng ở Phase 4) sau khi phá đảo Sa mạc
var minibosses_spawned := 0 # số Mini-boss đã sinh trong ván
var final_spawned := false  # đã sinh Final boss chưa
var won := false            # đã phá đảo (giết Final boss) chưa
var map_panel: PanelContainer
var map_title: Label
var map_btns: Array = []
var dead_pool_timer := 5.0   # đếm giờ sinh vũng độc ở Vùng đất chết
var dead_pools: Array = []   # mỗi phần tử: {node, pos, radius, t}
var gate: Node2D = null      # Cổng thoát hiểm đang mở (nếu có)
var gate_arrow: Polygon2D = null  # mũi tên chỉ hướng tới cổng khi ngoài màn hình
var decor_cells := {}
var stage := 0
var stages_announced: Array = []
var event_timer := 75.0
var frenzy_timer := 0.0
var crate_timer := 12.0
var bosses: Array = []
var arrows: Array = []
var arrows_holder := Node2D.new()
var chest_panel: PanelContainer
var chest_text: Label
var pause_panel: PanelContainer
var owned_artifacts: Array = []
var xp_gain := 1
var lang := 0  # 0 = Tiếng Việt, 1 = English
var gold := 0          # Vàng tích lũy (mua chỉ số Sinh tồn)
var souls := 0         # Mảnh Linh Hồn tích lũy (mua chỉ số Tấn công); KHÔNG mất khi chết
var run_gold := 0      # Vàng kiếm trong ván hiện tại (chưa gửi vào kho)
var run_souls := 0     # Mảnh Linh Hồn kiếm trong ván hiện tại
var meta_levels := {}  # id nâng cấp -> cấp đã mua
var difficulty := 1.0      # nhân máu quái theo số nâng cấp vĩnh viễn đã mua
var enemy_dmg_mult := 1.0  # nhân sát thương quái theo số nâng cấp đã mua
var _hitstop_cd := 0.0     # hồi chiêu hit-stop để không khựng liên tục
var _boom_shake_cd := 0.0  # hồi chiêu rung màn hình để tránh rung liên tục
var _deaths_this_frame := 0  # đếm quái chết trong khung hình để bắt "AoE diệt 3+"
var _rain_active := false
var _rain_fading := false
var _rain_cd := 40.0
var _rain_dur := 0.0
var _rain_slowing := false
var _rain_speed_backup := 0.0
var _rain_fog_sprs: Array = []
var _rain_prev_pos := Vector2.ZERO
var shop_panel: PanelContainer
var shop_title: Label
var shop_gold_label: Label
var shop_close: Button
var shop_open_btn: Button
var shop_rows: Array = []  # mỗi phần tử: {id, btn}
var shop_sec_labels: Array = []  # mỗi phần tử: {cur, label} — tiêu đề mục Vàng/Linh Hồn
var shop_nav_btns: Array = []  # các nút điều hướng bằng bàn phím trong shop (6 nâng cấp + Đóng)
var _shop_sel := 0
var chest_title: Label
var chest_btn: Button
var pause_title: Label
var pause_resume: Button
var pause_reset: Button
var lang_label: Label
var lang_btns: Array = []

var ground := Sprite2D.new()
var music := AudioStreamPlayer.new()
var die_sfx := AudioStreamPlayer.new()
var announce_font: FontVariation

@onready var player: CharacterBody2D = $Player
@onready var hp_bar: TextureProgressBar = $UI/HpBar
@onready var hp_label: Label = $UI/HpBar/HpLabel
@onready var time_label: Label = $UI/TimeLabel
@onready var xp_bar: TextureProgressBar = $UI/XpBar
@onready var level_label: Label = $UI/XpBar/LevelLabel
@onready var kills_label: Label = $UI/KillsLabel
@onready var over_label: Label = $UI/GameOverLabel
@onready var level_panel: PanelContainer = $UI/LevelUpPanel
@onready var char_panel: PanelContainer = $UI/CharSelectPanel
@onready var settings_panel: PanelContainer = $UI/SettingsPanel
@onready var sound_btn: Button = $UI/SoundBtn
@onready var music_slider: HSlider = $UI/SettingsPanel/VBox/MusicRow/Slider
@onready var sfx_slider: HSlider = $UI/SettingsPanel/VBox/SfxRow/Slider


func _ready() -> void:
	randomize()
	Engine.time_scale = 1.0  # an toàn: reset nếu còn kẹt do hit-stop ở ván trước
	announce_font = FontVariation.new()
	announce_font.base_font = FONT_ANNOUNCE
	announce_font.variation_opentype = {"wght": 800}
	for st: AudioStreamWAV in [MUSIC_MENU, MUSIC_GAME]:
		st.loop_mode = AudioStreamWAV.LOOP_FORWARD
		st.loop_end = st.data.size() / 4
	music.stream = MUSIC_MENU
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music)
	music.play()
	die_sfx.stream = SND_DIE
	add_child(die_sfx)
	sound_btn.pressed.connect(_toggle_settings)
	settings_panel.get_node("VBox/CloseBtn").pressed.connect(_toggle_settings)
	music_slider.value_changed.connect(_set_music_vol)
	sfx_slider.value_changed.connect(_set_sfx_vol)
	_set_music_vol(music_slider.value)
	_set_sfx_vol(sfx_slider.value)
	ground.texture = TEX_GRASS
	ground.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	ground.region_enabled = true
	ground.region_rect = Rect2(-2048, -2048, 4096, 4096)
	ground.z_index = -10
	add_child(ground)
	player.died.connect(_on_player_died)
	_update_decor()
	$UI.add_child(arrows_holder)
	_build_chest_panel()
	_build_pause_panel()
	$UI/PauseBtn.pressed.connect(_toggle_pause)
	var listener := Node.new()
	listener.set_script(preload("res://scripts/pause_listener.gd"))
	listener.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(listener)
	listener.toggled.connect(_toggle_pause)
	# Node điều hướng chọn nâng cấp bằng bàn phím (WASD/mũi tên + Space)
	var lvl_nav := Node.new()
	lvl_nav.set_script(preload("res://scripts/levelup_nav.gd"))
	lvl_nav.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(lvl_nav)
	lvl_nav.nav.connect(_ui_nav)
	lvl_nav.accept.connect(_ui_accept)
	lvl_nav.restart.connect(_on_restart)
	for i in 3:
		var lb: Button = level_panel.get_node("VBox/HBox/Btn%d" % (i + 1))
		lb.focus_mode = Control.FOCUS_NONE  # tránh Space kích hoạt nút đang focus (double-fire)
		lb.pressed.connect(_choose.bind(i))
	for i in 4:
		var cb: Button = char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1))
		cb.focus_mode = Control.FOCUS_NONE
		cb.pressed.connect(_pick_char.bind(i))
	# Phase 4: chỉ còn 4 nhân vật → ẩn 2 ô thừa trong lưới
	char_panel.get_node("VBox/Grid/CharBtn5").visible = false
	char_panel.get_node("VBox/Grid/CharBtn6").visible = false
	_load_lang()
	_load_meta()
	_build_lang_row()
	_build_shop_panel()
	_build_shop_button()
	_apply_lang()
	_skin_levelup()
	_skin_char_select()

	_build_debug_panel()
	_build_map_panel()
	_refresh_map_panel()
	_char_sel = 0
	_update_char_highlight()
	# Phase 1: chọn BẢN ĐỒ trước, rồi mới tới chọn nhân vật
	_map_sel = 0
	char_panel.visible = false
	map_panel.visible = true
	get_tree().paused = true


func T(key: String) -> String:
	return I18N[key][lang]


func _load_lang() -> void:
	var cf := ConfigFile.new()
	if cf.load("user://settings.cfg") == OK:
		lang = int(cf.get_value("ui", "lang", 0))


func _save_lang() -> void:
	var cf := ConfigFile.new()
	cf.set_value("ui", "lang", lang)
	cf.save("user://settings.cfg")


# ---------- Meta-progression: vàng + nâng cấp vĩnh viễn ----------

func _load_meta() -> void:
	var cf := ConfigFile.new()
	if cf.load("user://save.cfg") != OK:
		return
	gold = int(cf.get_value("meta", "gold", 0))
	souls = int(cf.get_value("meta", "souls", 0))
	unlocked_maps = int(cf.get_value("meta", "unlocked_maps", 1))
	ronin_unlocked = bool(cf.get_value("meta", "ronin_unlocked", false))
	for u in META_UPGRADES:
		meta_levels[u["id"]] = int(cf.get_value("upgrades", u["id"], 0))


func _save_meta() -> void:
	var cf := ConfigFile.new()
	cf.set_value("meta", "gold", gold)
	cf.set_value("meta", "souls", souls)
	cf.set_value("meta", "unlocked_maps", unlocked_maps)
	cf.set_value("meta", "ronin_unlocked", ronin_unlocked)
	for u in META_UPGRADES:
		cf.set_value("upgrades", u["id"], int(meta_levels.get(u["id"], 0)))
	cf.save("user://save.cfg")


func _apply_meta_upgrades() -> void:
	var total := 0
	for u in META_UPGRADES:
		var lvl := int(meta_levels.get(u["id"], 0))
		total += lvl
		if lvl <= 0:
			continue
		player.set(u["prop"], player.get(u["prop"]) + float(u["amount"]) * lvl)
	player.hp = player.max_hp
	# Mỗi cấp nâng cấp vĩnh viễn làm quái mạnh thêm để bù lại sức mạnh người chơi
	# (giảm nhẹ để người chơi thực sự cảm thấy mạnh lên khi đầu tư Vàng)
	difficulty = 1.0 + total * 0.015      # +1.5% máu quái mỗi cấp
	enemy_dmg_mult = 1.0 + total * 0.015  # +1.5% sát thương quái mỗi cấp


func _meta_by_id(id: String) -> Dictionary:
	for u in META_UPGRADES:
		if u["id"] == id:
			return u
	return {}


func _upgrade_cost(u: Dictionary, lvl: int) -> int:
	return int(u["base"]) * (lvl + 1)


func _build_shop_panel() -> void:
	shop_panel = PanelContainer.new()
	shop_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	shop_panel.visible = false
	shop_panel.custom_minimum_size = Vector2(620, 0)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	shop_title = Label.new()
	shop_title.add_theme_font_size_override("font_size", 26)
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(shop_title)
	shop_gold_label = Label.new()
	shop_gold_label.add_theme_font_size_override("font_size", 20)
	shop_gold_label.add_theme_color_override("font_color", Color(0.85, 0.6, 0.05))
	shop_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(shop_gold_label)
	# Tách nâng cấp theo loại tiền: Vàng (cột trái) / Linh Hồn (cột phải)
	var gold_ups := []
	var soul_ups := []
	for u in META_UPGRADES:
		if String(u.get("cur", "gold")) == "soul":
			soul_ups.append(u)
		else:
			gold_ups.append(u)
	# Hàng tiêu đề 2 mục đặt trên 2 cột
	var sec_row := HBoxContainer.new()
	sec_row.add_theme_constant_override("separation", 12)
	for cur in ["gold", "soul"]:
		var sec := Label.new()
		sec.add_theme_font_size_override("font_size", 15)
		sec.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sec.add_theme_color_override("font_color",
			Color(0.85, 0.6, 0.05) if cur == "gold" else Color(0.6, 0.45, 0.95))
		sec_row.add_child(sec)
		shop_sec_labels.append({"cur": cur, "label": sec})
	vbox.add_child(sec_row)
	# Lưới 2 cột: trái = nâng cấp Vàng, phải = nâng cấp Linh Hồn
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	var rows := maxi(gold_ups.size(), soul_ups.size())
	for i in rows:
		for col_list in [gold_ups, soul_ups]:
			if i >= col_list.size():
				grid.add_child(Control.new())  # ô trống nếu lệch số lượng
				continue
			var u: Dictionary = col_list[i]
			var b := Button.new()
			b.add_theme_font_size_override("font_size", 17)
			b.custom_minimum_size = Vector2(0, 60)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.focus_mode = Control.FOCUS_NONE
			b.pressed.connect(_buy_upgrade.bind(String(u["id"])))
			# Viền vàng cho nâng cấp mua bằng vàng, tím cho mua bằng linh hồn
			var accent: Color = Color(0.7, 0.55, 1.0) if String(u.get("cur", "gold")) == "soul" else Color(1.0, 0.78, 0.3)
			_skin_menu_button(b, accent)
			grid.add_child(b)
			shop_rows.append({"id": u["id"], "btn": b})
	vbox.add_child(grid)
	shop_close = Button.new()
	shop_close.add_theme_font_size_override("font_size", 20)
	shop_close.custom_minimum_size = Vector2(0, 40)
	shop_close.focus_mode = Control.FOCUS_NONE
	shop_close.pressed.connect(_close_shop)
	_skin_menu_button(shop_close, Color(0.9, 0.5, 0.45))
	vbox.add_child(shop_close)
	# Danh sách nút điều hướng bằng bàn phím: 6 nâng cấp rồi tới nút Đóng
	for row in shop_rows:
		shop_nav_btns.append(row["btn"])
	shop_nav_btns.append(shop_close)
	shop_panel.add_child(vbox)
	$UI.add_child(shop_panel)
	_skin_menu_panel(shop_panel, 16.0)
	_style_menu_title(shop_title)
	shop_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	shop_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	shop_panel.grow_vertical = Control.GROW_DIRECTION_BOTH


func _build_shop_button() -> void:
	shop_open_btn = Button.new()
	shop_open_btn.add_theme_font_size_override("font_size", 20)
	shop_open_btn.focus_mode = Control.FOCUS_NONE
	shop_open_btn.pressed.connect(_open_shop)
	char_panel.get_node("VBox").add_child(shop_open_btn)


func _open_shop() -> void:
	char_panel.visible = false
	_shop_sel = 0
	_refresh_shop()
	shop_panel.visible = true


func _close_shop() -> void:
	shop_panel.visible = false
	char_panel.visible = true
	_update_char_highlight()
	_update_shop_btn_label()


func _buy_upgrade(id: String) -> void:
	var u := _meta_by_id(id)
	var lvl := int(meta_levels.get(id, 0))
	if lvl >= int(u["max"]):
		return
	var cost := _upgrade_cost(u, lvl)
	if String(u.get("cur", "gold")) == "soul":
		if souls < cost:
			return
		souls -= cost
	else:
		if gold < cost:
			return
		gold -= cost
	meta_levels[id] = lvl + 1
	_save_meta()
	_refresh_shop()


func _refresh_shop() -> void:
	if shop_gold_label == null:
		return
	shop_gold_label.text = T("shop_balance") % [gold, souls]
	for sec in shop_sec_labels:
		sec["label"].text = T("shop_sec_gold") if sec["cur"] == "gold" else T("shop_sec_soul")
	for row in shop_rows:
		var u := _meta_by_id(String(row["id"]))
		var lvl := int(meta_levels.get(u["id"], 0))
		var b: Button = row["btn"]
		var is_soul := String(u.get("cur", "gold")) == "soul"
		var sym := "🔮" if is_soul else "💰"
		var bal := souls if is_soul else gold
		if lvl >= int(u["max"]):
			b.text = T("shop_max") % [u["name"][lang], u["unit"]]
			b.disabled = true
		else:
			var cost := _upgrade_cost(u, lvl)
			b.text = T("shop_buy") % [u["name"][lang], lvl, int(u["max"]), u["unit"], cost, sym]
			b.disabled = bal < cost
	if not shop_nav_btns.is_empty():
		_update_shop_highlight()
	_update_shop_btn_label()


func _update_shop_highlight() -> void:
	for i in shop_nav_btns.size():
		shop_nav_btns[i].modulate = Color(1.4, 1.4, 1.4) if i == _shop_sel else Color(0.8, 0.8, 0.8)


func _shop_accept() -> void:
	if _shop_sel < shop_rows.size():
		_buy_upgrade(String(shop_rows[_shop_sel]["id"]))
		_update_shop_highlight()
	else:
		_close_shop()


func _update_shop_btn_label() -> void:
	if shop_open_btn:
		shop_open_btn.text = T("shop_btn") % [gold, souls]


func _build_lang_row() -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	lang_label = Label.new()
	lang_label.add_theme_font_size_override("font_size", 20)
	lang_label.add_theme_color_override("font_color", Color(0.15, 0.17, 0.25))
	row.add_child(lang_label)
	for i in 2:
		var b := Button.new()
		b.text = ["Tiếng Việt", "English"][i]
		b.add_theme_font_size_override("font_size", 20)
		b.toggle_mode = true
		b.pressed.connect(_set_lang.bind(i))
		row.add_child(b)
		lang_btns.append(b)
	var vbox := char_panel.get_node("VBox")
	vbox.add_child(row)
	vbox.move_child(row, 1)


func _set_lang(l: int) -> void:
	lang = l
	_save_lang()
	_apply_lang()


func _apply_lang() -> void:
	level_panel.get_node("VBox/Title").text = T("levelup_title")
	char_panel.get_node("VBox/Title").text = T("char_title")
	settings_panel.get_node("VBox/Title").text = T("sound_title")
	settings_panel.get_node("VBox/MusicRow/Label").text = T("music")
	settings_panel.get_node("VBox/SfxRow/Label").text = T("sfx")
	settings_panel.get_node("VBox/CloseBtn").text = T("close")
	chest_title.text = T("chest_title")
	chest_btn.text = T("chest_take")
	pause_title.text = T("pause_title")
	pause_resume.text = T("resume")
	pause_reset.text = T("reselect")
	lang_label.text = T("lang_label")
	shop_title.text = T("shop_title")
	shop_close.text = T("shop_close")
	_refresh_shop()
	for i in lang_btns.size():
		lang_btns[i].button_pressed = (i == lang)
	for i in 4:
		var btn: Button = char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1))
		var c: Dictionary = CHARACTERS[i]
		var locked: bool = c.get("locked", false) and not ronin_unlocked
		btn.icon = c["tex"]
		if locked:
			btn.text = "%s  %s\n%s" % [c["name"][lang], T("map_locked"), c["weapon_short"][lang]]
		else:
			btn.text = "%s\n%s" % [c["name"][lang], c["weapon_short"][lang]]
	_refresh_map_panel()


func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible


func _set_music_vol(v: float) -> void:
	# Nhạc menu phát nhỏ hơn nhạc trong trận
	var extra := -8.0 if music.stream == MUSIC_MENU else 0.0
	music.volume_db = (linear_to_db(v) + extra) if v > 0.0 else -80.0


func _set_sfx_vol(v: float) -> void:
	var db := linear_to_db(v) if v > 0.0 else -80.0
	player.shoot_sfx.volume_db = db
	player.boom_sfx.volume_db = db
	player.zap_sfx.volume_db = db
	die_sfx.volume_db = db


func _pick_char(i: int) -> void:
	var c: Dictionary = CHARACTERS[i]
	if c.get("locked", false) and not ronin_unlocked:
		return  # Kiếm khách chưa mở khóa
	player.get_node("Sprite2D").texture = c["tex"]
	player.max_hp = c["hp"]
	player.hp = c["hp"]
	player.speed = c["speed"]
	player.fire_rate = c["fire"]
	player.projectile_damage = c["dmg"]
	player.projectile_count = c["count"]
	player.pierce = c["pierce"]
	player.weapon = c["weapon"]
	_apply_meta_upgrades()
	char_panel.visible = false
	get_tree().paused = false
	_rain_active = false
	_rain_fading = false
	_rain_cd = 40.0
	if _rain_slowing and is_instance_valid(player):
		player.speed = _rain_speed_backup
	_rain_slowing = false
	for spr in _rain_fog_sprs:
		if is_instance_valid(spr):
			spr.queue_free()
	_rain_fog_sprs.clear()
	_setup_stage()  # áp dụng map đã chọn: nền, nhạc, hiệu ứng vùng


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	# Hit-stop khi AoE hạ gục từ 3 quái trở lên cùng lúc (gom theo khung hình)
	if _deaths_this_frame >= 3:
		request_hit_stop(0.06)
	_deaths_this_frame = 0
	_kill_blast_budget = 3  # giới hạn nổ "Nổ Chùm" mỗi khung hình
	if _hitstop_cd > 0.0:
		_hitstop_cd = maxf(0.0, _hitstop_cd - delta)

	ground.global_position = player.global_position.snapped(Vector2(64.0, 64.0))
	_update_decor()

	time += delta
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = maxf(0.35, 1.1 - time * 0.015)
		_spawn_enemy()

	# Nhịp boss theo mốc: Mini-boss phút 5 & 10, Final boss phút 15
	if minibosses_spawned < MINIBOSS_TIMES.size() and time >= float(MINIBOSS_TIMES[minibosses_spawned]):
		minibosses_spawned += 1
		_spawn_boss(false)
	if not final_spawned and time >= FINAL_TIME:
		final_spawned = true
		_spawn_boss(true)

	# Vùng đất chết: định kỳ tạo vũng độc quanh người chơi
	if selected_stage == 2:
		_dead_pool_tick(delta)

	_rain_tick(delta)

	# Lõi Cuồng nộ: chu kỳ x2 chỉ số
	if chosen_core == "frenzy":
		_frenzy_core_tick(delta)

	event_timer -= delta
	if event_timer <= 0.0:
		event_timer = randf_range(100.0, 140.0)
		_trigger_event()

	crate_timer -= delta
	if crate_timer <= 0.0:
		crate_timer = randf_range(18.0, 26.0)
		_spawn_crate()

	if frenzy_timer > 0.0:
		frenzy_timer -= delta
		if frenzy_timer <= 0.0:
			for e in get_tree().get_nodes_in_group("enemies"):
				if e.has_meta("fz"):
					e.speed /= 1.45
					e.remove_meta("fz")

	_update_arrows()
	_update_gate_arrow()

	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	hp_label.text = T("hp_fmt") % [int(player.hp), int(player.max_hp)]
	time_label.text = "%02d:%02d" % [int(time) / 60, int(time) % 60]
	xp_bar.max_value = xp_needed
	xp_bar.value = xp
	level_label.text = T("level_fmt") % [level, xp, xp_needed]
	kills_label.text = T("kills_fmt") % kills


func _setup_stage() -> void:
	# Phase 1: map cố định cả ván (không còn tự xoay vòng). Gọi 1 lần khi vào trận.
	stage = selected_stage
	var cfg: Dictionary = STAGES[stage]
	ground.texture = cfg["tile"]
	ground.modulate = cfg["tile_mod"]
	for cell in decor_cells.keys():
		decor_cells[cell].queue_free()
	decor_cells.clear()
	_update_decor()
	_announce(T("stage_fmt") % cfg["name"][lang], Color(0.55, 1.0, 0.75))
	# Sa mạc: đi trên cát chậm hơn
	player.stage_speed_mult = 0.82 if stage == 1 else 1.0
	match stage:
		0: _change_music(MUSIC_GAME)
		1: _change_music(MUSIC_DESERT)
		2: _change_music(MUSIC_DEAD)


func _change_music(new_stream: AudioStream) -> void:
	if music.stream == new_stream:
		return
	var tw := create_tween()
	tw.tween_property(music, "volume_db", -80.0, 0.9)
	tw.tween_callback(func() -> void:
		music.stream = new_stream
		_set_music_vol(music_slider.value)
		music.play()
	)


func _apply_stage(e: Area2D) -> void:
	# Khó dần theo số nâng cấp vĩnh viễn đã mua
	e.hp *= difficulty
	e.dps *= enemy_dmg_mult
	e.bullet_damage *= enemy_dmg_mult
	match stage:
		1:
			e.hp *= 1.15
			e.speed *= 1.05
			e.tint = e.tint * Color(1.0, 0.82, 0.55)
		2:
			e.hp *= 1.4
			e.speed *= 1.1
			e.tint = e.tint * Color(0.72, 0.62, 1.0)
			e.gems += 1


func _update_decor() -> void:
	var center := Vector2i((player.global_position / DECOR_CELL).floor())
	for dy in range(-4, 5):
		for dx in range(-4, 5):
			var cell := center + Vector2i(dx, dy)
			if not decor_cells.has(cell):
				decor_cells[cell] = _spawn_decor_cell(cell)
	for cell: Vector2i in decor_cells.keys():
		if absi(cell.x - center.x) > 6 or absi(cell.y - center.y) > 6:
			decor_cells[cell].queue_free()
			decor_cells.erase(cell)


func _spawn_decor_cell(cell: Vector2i) -> Node2D:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(cell)
	var holder := Node2D.new()
	holder.z_index = -8
	holder.modulate = STAGES[stage]["decor_mod"]
	add_child(holder)
	var decor: Array = STAGES[stage]["decor"]
	for i in rng.randi_range(1, 3):
		var d: Dictionary = decor[rng.randi_range(0, decor.size() - 1)]
		if rng.randf() > d.get("chance", 1.0):
			continue
		var s := Sprite2D.new()
		s.texture = d["tex"]
		s.position = Vector2(cell) * DECOR_CELL + Vector2(rng.randf_range(20.0, DECOR_CELL - 20.0), rng.randf_range(20.0, DECOR_CELL - 20.0))
		s.rotation = 0.0 if d.get("no_rot", false) else rng.randf_range(-0.4, 0.4)
		s.scale = Vector2.ONE * rng.randf_range(d["s"][0], d["s"][1])
		if d.get("flat", false):
			s.z_index = -1
		holder.add_child(s)
	return holder


func _make_enemy() -> Area2D:
	var e := Area2D.new()
	e.set_script(ENEMY)
	e.player = player
	e.died.connect(_on_enemy_died)
	e.summon.connect(_on_boss_summon)
	e.tornado.connect(_on_boss_tornado)
	e.quicksand.connect(_on_boss_quicksand)
	return e


func _spawn_enemy() -> void:
	var e := _make_enemy()
	var r := randf()
	if time > 45.0 and r < 0.15:
		e.tex = TEX_ROBOT
		e.hp = (2.5 + time * 0.05) * 6.0
		e.speed = 55.0
		e.dps = 25.0
		e.gems = 3
	elif time > 28.0 and r < 0.28:
		# Xạ thủ: giữ khoảng cách và bắn đạn về phía người chơi
		e.tex = TEX_HITMAN
		e.tint = Color(0.5, 1.0, 0.6)
		e.kind = ENEMY.Kind.RANGER
		e.hp = (2.5 + time * 0.05) * 1.8
		e.speed = 110.0
		e.bullet_damage = 8.0
		e.gems = 2
	elif time > 18.0 and r < 0.45:
		e.tex = TEX_HITMAN
		e.hp = (2.5 + time * 0.05) * 1.2
		e.speed = minf(145.0 + time * 0.5, 250.0)
		e.gems = 1
	else:
		e.hp = (2.5 + time * 0.05) * 2.0
		e.speed = minf(90.0 + time * 0.6, 190.0)
	if time > 45.0 and e.kind == ENEMY.Kind.MELEE and randf() < 0.06:
		_make_elite(e)
	# Vùng đất chết (hardcore): quái cận chiến hồi sinh 1 lần
	if selected_stage == 2 and e.kind == ENEMY.Kind.MELEE:
		e.can_revive = true
	_apply_stage(e)
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 550.0
	if frenzy_timer > 0.0:
		e.speed *= 1.45
		e.set_meta("fz", true)


func _spawn_boss(is_final: bool) -> void:
	boss_count += 1
	var e := _make_enemy()
	e.kind = ENEMY.Kind.BOSS
	e.sprite_scale = 1.5
	e.hp = 40.0 + time * 1.2
	e.dps = 30.0
	e.gems = 8
	var announce := T("miniboss_announce")
	# Final boss luôn là boss đặc trưng của map; Mini-boss thì ngẫu nhiên như cũ
	var themed := stage != 0 and (is_final or randf() < 0.5)
	if stage == 1 and themed:
		# Hung thần sa mạc: thả lốc cát đuổi theo, tạo vũng cát lún, biết lao tới
		e.tex = TEX_BOSS_DESERT
		e.upright = true
		e.vis_scale = 0.5
		e.speed = 80.0
		e.skills = ["tornado", "quicksand", "dash"]
		e.skill_interval = 5.0
		announce = T("boss_desert")
	elif stage == 2 and themed:
		# Chúa tể xương: gọi đệ xương liên tục, bắn đạn xoắn ốc và vòng toả tròn
		e.tex = TEX_BOSS_BONE
		e.upright = true
		e.vis_scale = 0.5
		e.speed = 60.0
		e.bullet_damage = 11.0
		e.skills = ["summon", "spiral", "burst"]
		e.skill_interval = 5.5
		announce = T("boss_dead")
	else:
		# Final boss Đồng cỏ luôn là "Đại tướng" (chỉ-số 3 trong TOPDOWN_BOSSES)
		announce = _apply_topdown_boss(e, 3 if (is_final and stage == 0) else -1)
	if is_final:
		# Boss cuối to và mạnh hơn hẳn; Vùng đất chết nhân đôi thông số (Zombie Chúa)
		announce = T("final_announce")
		e.sprite_scale *= 1.35
		e.vis_scale *= 1.35 if e.vis_scale > 0.0 else 1.0
		e.hp *= (2.0 if stage == 2 else 1.6)
		e.dps *= (2.0 if stage == 2 else 1.4)
		e.gems = 20
	_apply_stage(e)
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 600.0
	bosses.append(e)
	e.died.connect(func(pos: Vector2, _g: int) -> void: _spawn_chest(pos))
	# Mảnh Linh Hồn chỉ rớt từ boss: Mini-boss 1, Final boss 3-5
	var soul_drop := randi_range(3, 5) if is_final else 1
	e.died.connect(func(_pos: Vector2, _g: int) -> void: run_souls += soul_drop)
	if is_final:
		e.died.connect(func(_pos: Vector2, _g: int) -> void: _win_run())
	else:
		# Giết Mini-boss → mở Cổng thoát hiểm (rút lui an toàn hoặc tất tay đánh tiếp)
		e.died.connect(func(_pos: Vector2, _g: int) -> void: _spawn_extraction_gate())
	_announce(announce, Color(1.0, 0.2, 0.2), 8.0)


func _win_run() -> void:
	if won:
		return
	won = true
	game_over = true
	Engine.time_scale = 1.0
	# Phá đảo = giữ 100% Vàng và Mảnh Linh Hồn kiếm được
	gold += run_gold
	souls += run_souls
	# Mở khóa map kế tiếp khi phá đảo đúng map mới nhất
	var unlock_msg := ""
	if selected_stage == 0 and unlocked_maps < 2:
		unlocked_maps = 2
		unlock_msg = T("win_unlock") % STAGES[1]["name"][lang]
	elif selected_stage == 1:
		if unlocked_maps < 3:
			unlocked_maps = 3
			unlock_msg = T("win_unlock") % STAGES[2]["name"][lang]
		ronin_unlocked = true  # phá đảo Sa mạc mở khóa Kiếm khách (Phase 4)
	_save_meta()
	over_label.text = (T("win_fmt") % [STAGES[selected_stage]["name"][lang], kills]) \
		+ (T("reward_fmt") % [run_gold, run_souls]) + unlock_msg
	over_label.visible = true
	get_tree().paused = true  # dừng toàn bộ thế giới khi hiện menu thắng


func _spawn_extraction_gate() -> void:
	if is_instance_valid(gate):
		return  # chỉ một cổng tại một thời điểm
	var g := Node2D.new()
	g.set_script(EXTRACTION_GATE)
	g.player = player
	g.title = T("gate_label")
	g.extracted.connect(_extract)
	g.expired.connect(_on_gate_expired)
	add_child(g)
	g.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(600.0, 800.0)
	gate = g
	_announce(T("gate_announce"), Color(0.5, 1.0, 0.9), 4.0)


func _on_gate_expired() -> void:
	gate = null
	_announce(T("gate_closed"), Color(0.6, 0.8, 0.9))


func _extract() -> void:
	if game_over:
		return
	game_over = true
	Engine.time_scale = 1.0
	gate = null
	# Rút lui an toàn = giữ 100% Vàng + Mảnh Linh Hồn (không mở khóa map)
	gold += run_gold
	souls += run_souls
	_save_meta()
	over_label.text = (T("extract_fmt") % [STAGES[selected_stage]["name"][lang], kills]) \
		+ (T("reward_fmt") % [run_gold, run_souls])
	over_label.visible = true
	get_tree().paused = true  # dừng toàn bộ thế giới khi rút lui


func _update_gate_arrow() -> void:
	if gate_arrow == null:
		gate_arrow = Polygon2D.new()
		gate_arrow.polygon = PackedVector2Array([Vector2(18, 0), Vector2(-11, 11), Vector2(-11, -11)])
		gate_arrow.color = Color(0.4, 1.0, 0.85)
		gate_arrow.visible = false
		arrows_holder.add_child(gate_arrow)
	if not is_instance_valid(gate):
		gate_arrow.visible = false
		return
	var to_gate: Vector2 = gate.global_position - player.global_position
	if to_gate.length() <= 360.0:
		gate_arrow.visible = false
		return
	gate_arrow.visible = true
	var center := get_viewport_rect().size * 0.5
	gate_arrow.position = center + to_gate.normalized() * 230.0
	gate_arrow.rotation = to_gate.angle()
	gate_arrow.scale = Vector2.ONE * (1.0 + 0.25 * sin(time * 7.0))


func _apply_topdown_boss(e: Area2D, force_idx := -1) -> String:
	# Boss gắn cờ "meadow_only" chỉ được chọn khi đang ở Đồng cỏ (stage 0)
	var pool: Array = TOPDOWN_BOSSES.filter(func(b: Dictionary) -> bool: return stage == 0 or not b.get("meadow_only", false))
	var m: Dictionary = TOPDOWN_BOSSES[force_idx] if (force_idx >= 0 and force_idx < TOPDOWN_BOSSES.size()) else pool[boss_count % pool.size()]
	e.tex = m["tex"]
	e.tint = m["tint"]
	e.sprite_scale = 2.2  # to gấp ~1.5 lần boss thường để ra dáng boss
	e.speed = float(m["speed"])
	e.bullet_damage = float(m["bullet"])
	e.skills = m["skills"]
	e.skill_interval = 5.0
	return m["name"][lang]


func _on_boss_summon(pos: Vector2) -> void:
	spawn_explosion(pos, 110.0, 0.4)
	# Vùng đất chết: đệ là bộ xương trắng, nhanh và đông hơn
	var count := 6 if stage == 2 else 4
	for i in count:
		var e := _make_enemy()
		e.tint = Color(1.1, 1.1, 1.25) if stage == 2 else Color(0.7, 1.0, 0.7)
		e.sprite_scale = 0.6
		e.hp = (2.5 + time * 0.05) * 0.7
		e.speed = minf(75.0 + time * 0.6, 165.0) * (1.15 if stage == 2 else 1.0)
		e.gems = 1
		_apply_stage(e)
		add_child(e)
		e.global_position = pos + Vector2.from_angle(TAU * i / count + randf() * 0.5) * 60.0


func _on_boss_tornado(pos: Vector2) -> void:
	var t := Node2D.new()
	t.set_script(TORNADO)
	t.player = player
	add_child(t)
	t.global_position = pos + Vector2.from_angle(randf() * TAU) * 50.0


func _on_boss_quicksand(pos: Vector2) -> void:
	# Tạo 3 vũng cát lún quanh vị trí người chơi, hiện dần để kịp né
	for i in 3:
		var q := Node2D.new()
		q.set_script(QUICKSAND)
		q.player = player
		add_child(q)
		q.global_position = pos + Vector2.from_angle(TAU * i / 3.0 + randf() * 1.5) * randf_range(0.0, 130.0)


func request_hit_stop(duration := 0.05) -> void:
	# Khựng khung hình rất ngắn để tạo cảm giác va đập (crit / AoE diệt nhiều quái)
	if game_over or choosing or _hitstop_cd > 0.0:
		return
	_hitstop_cd = 0.2
	Engine.time_scale = 0.001
	# Hẹn giờ chạy theo thời gian thực (bỏ qua time_scale) để khôi phục tốc độ
	var t := get_tree().create_timer(duration, true, false, true)
	t.timeout.connect(func() -> void: Engine.time_scale = 1.0)


func boom_shake(amt: float) -> void:
	# Cho các vũ khí nổ (pháo/lựu đạn/nova...) rung màn hình qua camera người chơi
	var now := Time.get_ticks_msec() / 1000.0
	if is_instance_valid(player) and now >= _boom_shake_cd:
		player.shake_amt = maxf(player.shake_amt, amt)
		_boom_shake_cd = now + 0.25


func _on_enemy_died(pos: Vector2, gem_count: int) -> void:
	kills += 1
	_deaths_this_frame += 1
	_spawn_coin(pos, gem_count)  # Vàng rơi ra nhặt như gem (giá trị theo độ "ngon" của quái)
	_spawn_death_fx(pos)
	die_sfx.pitch_scale = randf_range(0.85, 1.15)
	die_sfx.play()
	for i in gem_count:
		_spawn_gem(pos)
	if randf() < 0.008:
		_spawn_pickup(pos)
	# Hình thái "Hút Hồn": mỗi lần giết hồi 0.5 HP
	if player.sig_lifedrain_on_kill and is_instance_valid(player):
		player.heal(0.5)


func _spawn_gem(pos: Vector2, value := 1) -> void:
	var g := Area2D.new()
	g.set_script(GEM)
	g.player = player
	g.value = value
	g.collected.connect(_on_gem_collected)
	add_child(g)
	g.global_position = pos + Vector2.from_angle(randf() * TAU) * (randf() * 20.0)


func _spawn_coin(pos: Vector2, value: int) -> void:
	if value <= 0:
		return
	var c := Area2D.new()
	c.set_script(COIN)
	c.player = player
	c.value = value
	c.collected.connect(_on_coin_collected)
	add_child(c)
	c.global_position = pos + Vector2.from_angle(randf() * TAU) * (randf() * 22.0)


func _on_coin_collected(value: int) -> void:
	run_gold += value


func _make_elite(e: Area2D) -> void:
	var mod: String = ["regen", "split", "explode"].pick_random()
	e.elite_mod = mod
	e.sprite_scale *= 1.3
	e.hp *= 3.5
	e.speed *= 0.9
	e.gems += 1
	e.died.connect(func(pos: Vector2, _g: int) -> void: _on_elite_died(pos, mod))


func _on_elite_died(pos: Vector2, mod: String) -> void:
	_spawn_gem(pos, 5)
	match mod:
		"split":
			for i in 2:
				var m := _make_enemy()
				m.sprite_scale = 0.5
				m.tint = Color(0.7, 0.9, 1.4)
				m.hp = (2.5 + time * 0.05) * 0.5
				m.speed = minf(95.0 + time * 0.6, 180.0)
				_apply_stage(m)
				add_child(m)
				m.global_position = pos + Vector2.from_angle(randf() * TAU) * 30.0
		"explode":
			_elite_blast(pos)


func _elite_blast(pos: Vector2) -> void:
	# Vòng đỏ cảnh báo hiện dần rồi nổ — đứng trong vùng sẽ mất máu
	var warn := Sprite2D.new()
	warn.texture = CIRCLE
	warn.modulate = Color(1.0, 0.25, 0.15, 0.0)
	warn.scale = Vector2.ONE * (130.0 / 30.0)
	warn.z_index = -2
	add_child(warn)
	warn.global_position = pos
	var tw := warn.create_tween()
	tw.tween_property(warn, "modulate:a", 0.4, 0.8)
	tw.tween_callback(func() -> void:
		if is_instance_valid(player) and player.global_position.distance_to(pos) < 130.0:
			player.take_damage(25.0)
		spawn_explosion(pos, 260.0, 0.5)
		player.shake_amt = maxf(player.shake_amt, 3.5)
		warn.queue_free())


func _spawn_pickup(pos: Vector2, kind := "") -> void:
	if kind == "":
		var _r := randf()
		if _r < 0.10:
			kind = "heal"
		elif _r < 0.55:
			kind = "magnet"
		else:
			kind = "bomb"
	var p := Area2D.new()
	p.set_script(PICKUP)
	p.player = player
	p.kind = kind
	match kind:
		"heal":
			p.icon = ICON_PICK_HEAL
			p.glow_col = Color(0.4, 1.0, 0.45)
		"magnet":
			p.icon = ICON_PICK_MAGNET
			p.glow_col = Color(0.4, 0.8, 1.0)
		"bomb":
			p.icon = ICON_PICK_BOMB
			p.glow_col = Color(1.0, 0.55, 0.25)
	p.taken.connect(_apply_pickup)
	add_child(p)
	p.global_position = pos


func _apply_pickup(kind: String) -> void:
	match kind:
		"heal":
			player.heal(40.0)
		"magnet":
			for g in get_tree().get_nodes_in_group("gems"):
				g.force_pull = true
			for c in get_tree().get_nodes_in_group("coins"):
				c.force_pull = true
		"bomb":
			var bomb_radius := 280.0
			for e in get_tree().get_nodes_in_group("enemies"):
				if e.global_position.distance_to(player.global_position) <= bomb_radius:
					e.take_hit(60.0, true,
						(e.global_position - player.global_position).normalized() * 400.0,
						Color(1.0, 0.6, 0.3))
			spawn_explosion(player.global_position, bomb_radius * 2.0, 0.6)
			player.boom_sfx.pitch_scale = 0.8
			player.boom_sfx.play()
			player.shake_amt = 8.0


func _spawn_crate() -> void:
	if get_tree().get_nodes_in_group("crates").size() >= 4:
		return
	var c := Area2D.new()
	c.set_script(CRATE)
	c.player = player
	c.broke.connect(_on_crate_broke)
	add_child(c)
	c.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(420.0, 620.0)


func _on_crate_broke(pos: Vector2) -> void:
	spawn_explosion(pos, 90.0, 0.4)
	for i in 3:  # Vàng từ thùng gỗ — nổ ra một chùm đồng xu
		_spawn_coin(pos, randi_range(5, 12))
	if randf() < 0.7:
		_spawn_pickup(pos)
	else:
		for i in 3:
			_spawn_gem(pos)


func _spawn_death_fx(pos: Vector2) -> void:
	spawn_explosion(pos, 65.0, 0.4)


func spawn_explosion(pos: Vector2, diameter: float, duration := 0.55) -> void:
	var spr := Sprite2D.new()
	spr.texture = TEX_EXPLOSION
	spr.hframes = 8
	spr.vframes = 8
	spr.frame = 0
	spr.z_index = 16
	spr.scale = Vector2.ONE * (diameter / 100.0)
	add_child(spr)
	spr.global_position = pos
	var tw := spr.create_tween()
	tw.tween_property(spr, "frame", 63, duration)
	tw.tween_callback(spr.queue_free)


func _on_gem_collected(value: int) -> void:
	xp += value * xp_gain
	if xp >= xp_needed and not choosing:
		_show_level_up()


func _skin_levelup() -> void:
	# Panel ngoài: khung fantasy tối (Kenney Fantasy UI Borders)
	var psb := StyleBoxTexture.new()
	psb.texture = TEX_UI_PANEL
	psb.set_texture_margin_all(32.0)
	psb.set_content_margin_all(26.0)
	psb.modulate_color = Color(0.17, 0.16, 0.24)
	level_panel.add_theme_stylebox_override("panel", psb)
	# 3 thẻ: nền tối + khung viền tô màu theo độ hiếm (đặt ở _show_level_up)
	for i in 3:
		var btn: Button = level_panel.get_node("VBox/HBox/Btn%d" % (i + 1))
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.10, 0.10, 0.15)
		normal.set_corner_radius_all(12)
		var hover: StyleBoxFlat = normal.duplicate()
		hover.bg_color = Color(0.17, 0.17, 0.25)
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", normal)
		var frame := NinePatchRect.new()
		frame.texture = TEX_UI_FRAME
		frame.patch_margin_left = 32
		frame.patch_margin_top = 32
		frame.patch_margin_right = 32
		frame.patch_margin_bottom = 32
		frame.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(frame)
		card_frames.append(frame)


# --- Style menu dùng chung: khung fantasy tối giống panel lên cấp ---

# Nền panel: khung fantasy tối (Kenney Fantasy UI Borders)
func _skin_menu_panel(panel: PanelContainer, cm := 28.0) -> void:
	var psb := StyleBoxTexture.new()
	psb.texture = TEX_UI_PANEL
	psb.set_texture_margin_all(32.0)
	psb.set_content_margin_all(cm)
	psb.modulate_color = Color(0.16, 0.15, 0.22)
	panel.add_theme_stylebox_override("panel", psb)


# Tiêu đề menu: chữ vàng ấm + viền tối cho dễ đọc trên nền tối
func _style_menu_title(lbl: Label, col := Color(1.0, 0.86, 0.45)) -> void:
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_outline_color", Color(0.06, 0.05, 0.1))
	lbl.add_theme_constant_override("outline_size", 6)


# Thẻ lớn có thể chọn (nhân vật / bản đồ): nền tối bo góc + viền fantasy tô màu accent
func _skin_menu_card(btn: Button, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.11, 0.11, 0.16)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 16.0
	normal.content_margin_right = 16.0
	normal.content_margin_top = 10.0
	normal.content_margin_bottom = 12.0
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.18, 0.18, 0.27)
	var disabled: StyleBoxFlat = normal.duplicate()
	disabled.bg_color = Color(0.07, 0.07, 0.11)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(0.93, 0.93, 0.98))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.6))
	var frame := NinePatchRect.new()
	frame.texture = TEX_UI_FRAME
	frame.patch_margin_left = 32
	frame.patch_margin_top = 32
	frame.patch_margin_right = 32
	frame.patch_margin_bottom = 32
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.modulate = accent
	btn.add_child(frame)


# Nút phụ (ngôn ngữ / shop / đóng / hàng nâng cấp): nền tối bo góc + viền màu mảnh
func _skin_menu_button(btn: Button, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.13, 0.13, 0.19)
	normal.set_corner_radius_all(8)
	normal.set_border_width_all(2)
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.65)
	normal.content_margin_left = 14.0
	normal.content_margin_right = 14.0
	normal.content_margin_top = 7.0
	normal.content_margin_bottom = 8.0
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.2, 0.2, 0.3)
	hover.border_color = accent
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color(accent.r * 0.4, accent.g * 0.4, accent.b * 0.45, 1.0)
	pressed.border_color = accent
	var disabled: StyleBoxFlat = normal.duplicate()
	disabled.bg_color = Color(0.08, 0.08, 0.12)
	disabled.border_color = Color(0.3, 0.3, 0.35)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("hover_pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(0.93, 0.93, 0.98))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55))


# Áp style fantasy cho màn chọn nhân vật (panel dựng sẵn trong scene)
func _skin_char_select() -> void:
	_skin_menu_panel(char_panel)
	_style_menu_title(char_panel.get_node("VBox/Title"))
	# Mỗi nhân vật một màu viền theo vũ khí/vai trò, vẫn chung khung fantasy
	var accents := [
		Color(0.45, 0.75, 1.0),   # Lính đặc nhiệm — xanh thép
		Color(1.0, 0.7, 0.3),     # Ông già gân — hổ phách
		Color(0.55, 0.95, 0.55),  # Thợ săn — xanh lá
		Color(0.95, 0.45, 0.5),   # Kiếm khách — đỏ thẫm
	]
	for i in 4:
		var b: Button = char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1))
		_skin_menu_card(b, accents[i])
	if shop_open_btn:
		_skin_menu_button(shop_open_btn, Color(1.0, 0.82, 0.35))
	for lb in lang_btns:
		_skin_menu_button(lb, Color(0.72, 0.72, 0.88))
	if lang_label:
		lang_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.92))


func _show_level_up() -> void:
	choosing = true
	xp -= xp_needed
	# Đường cong XP mềm hơn: lên cấp liên tục, "ting ting" đều đặn cả late game
	xp_needed = int(xp_needed * 1.15) + 5
	level += 1
	player.heal(20.0)

	# Mốc Đan Chéo 5/10/15/20 chèn Nâng cấp Độc bản; còn lại là 3 thẻ ngẫu nhiên
	var cards := _milestone_cards(level)
	var is_milestone := not cards.is_empty()
	if not is_milestone:
		var pool := _build_pool()
		pool.shuffle()
		cards = pool.slice(0, 3)
	pending = cards
	_card_count = pending.size()
	_populate_level_panel(is_milestone)

	_sel = 0
	_update_levelup_highlight()
	level_panel.visible = true
	get_tree().paused = true


func _populate_level_panel(is_milestone: bool) -> void:
	var title := T("levelup_title")
	if is_milestone:
		match level:
			5:  title = T("sig_core_title")
			10: title = T("sig_enhance_title")
			15: title = T("sig_form_title")
			20: title = T("sig_ultimate_title")
	level_panel.get_node("VBox/Title").text = title

	# Thu hẹp panel theo số thẻ để viền ôm sát nội dung
	var _card_w := 228.0
	var _hbox_sep := 16.0
	var _margin_h := 52.0   # content_margin_left + right (26*2)
	var _inner_w := _card_w * pending.size() + _hbox_sep * maxf(pending.size() - 1, 0)
	var _half_w := minf((_inner_w + _margin_h) * 0.5 + 8.0, 380.0)
	level_panel.offset_left  = -_half_w
	level_panel.offset_right = _half_w

	# Căn dọc đối xứng: bù bottom margin = khoảng title+sep phía trên để cards nằm giữa panel
	var _margin_v := 26.0    # content_margin_top (từ _skin_levelup)
	var _title_h  := 50.0    # chiều cao 1 dòng font_size=32
	var _vbox_sep := 18.0    # VBox separation
	var _cards_h  := 280.0   # custom_minimum_size.y của Button
	var panel_sb := level_panel.get_theme_stylebox("panel") as StyleBoxTexture
	if panel_sb != null:
		panel_sb.set_content_margin(SIDE_BOTTOM, _title_h + _vbox_sep + _margin_v)
	var _half_h := _margin_v + _title_h + _vbox_sep + _cards_h * 0.5  # = 234
	level_panel.offset_top    = -_half_h
	level_panel.offset_bottom =  _half_h

	var hbox: HBoxContainer = level_panel.get_node("VBox/HBox")
	if pending.size() == 1:
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	else:
		hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	for i in 3:
		var b: Button = level_panel.get_node("VBox/HBox/Btn%d" % (i + 1))
		if i >= pending.size():
			b.visible = false
			continue
		b.visible = true
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if pending.size() == 1 else Control.SIZE_EXPAND_FILL
		var card: Dictionary = pending[i]
		var col := Color(0.5, 1.0, 0.6)  # chỉ số: xanh lá
		if card.has("col"):
			col = card["col"]
		else:
			var fn = card["fn"]
			if fn is String and fn.begins_with("_art"):
				col = Color(1.0, 0.78, 0.27)  # cổ vật: hổ phách
			elif fn is String and fn.begins_with("_evo"):
				col = Color(1.0, 0.4, 0.4)  # tiến hóa: đỏ
		b.get_node("V/Text").text = card["label"]
		var icon: TextureRect = b.get_node("V/Icon")
		icon.texture = card.get("icon", null)
		icon.modulate = col
		if i < card_frames.size():
			card_frames[i].self_modulate = col


func _update_levelup_highlight() -> void:
	# Làm nổi thẻ đang chọn, mờ các thẻ còn lại — chỉ dẫn rõ cho điều khiển bàn phím
	for i in 3:
		var b: Button = level_panel.get_node("VBox/HBox/Btn%d" % (i + 1))
		if i >= _card_count:
			continue
		b.modulate = Color(1.35, 1.35, 1.35) if i == _sel else Color(0.7, 0.7, 0.7)


func _ui_nav(dx: int, dy: int) -> void:
	# Định tuyến phím điều hướng tới màn đang mở
	if choosing:
		_sel = wrapi(_sel + dx + dy, 0, maxi(1, _card_count))
		_update_levelup_highlight()
	elif chest_panel.visible:
		pass  # rương chỉ có 1 nút, không cần di chuyển
	elif shop_panel != null and shop_panel.visible:
		_shop_sel = wrapi(_shop_sel + dx + dy, 0, shop_nav_btns.size())
		_update_shop_highlight()
	elif map_panel != null and map_panel.visible:
		_map_sel = wrapi(_map_sel + dx + dy, 0, 3)
		_update_map_highlight()
	elif char_panel.visible:
		_char_nav(dx, dy)


func _ui_accept() -> void:
	if choosing:
		_choose(_sel)
	elif chest_panel.visible:
		_close_chest()
	elif shop_panel != null and shop_panel.visible:
		_shop_accept()
	elif map_panel != null and map_panel.visible:
		_pick_map(_map_sel)
	elif char_panel.visible and not shop_panel.visible:
		if _char_sel >= 4:
			_open_shop()
		else:
			_pick_char(_char_sel)


func _char_nav(dx: int, dy: int) -> void:
	# Lưới 2 cột × 2 hàng nhân vật (0..3) + nút Shop là chỉ số 4
	if _char_sel >= 4:  # đang ở nút Shop
		if dy < 0:
			_char_sel = 2   # lên → hàng nhân vật dưới
		elif dy > 0:
			_char_sel = 0   # xuống → vòng lên hàng đầu
		_update_char_highlight()
		return
	var col := _char_sel % 2
	var row := _char_sel / 2
	if dx != 0:
		col = wrapi(col + dx, 0, 2)
		_char_sel = row * 2 + col
	elif dy != 0:
		var nr := row + dy
		if nr > 1 or nr < 0:
			_char_sel = 4   # ra khỏi lưới nhân vật → tới nút Shop
		else:
			_char_sel = nr * 2 + col
	_update_char_highlight()


func _update_char_highlight() -> void:
	for i in 4:
		var b: Button = char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1))
		b.modulate = Color(1.35, 1.35, 1.35) if i == _char_sel else Color(0.7, 0.7, 0.7)
	if shop_open_btn:
		shop_open_btn.modulate = Color(1.35, 1.35, 1.35) if _char_sel == 4 else Color(0.85, 0.85, 0.85)


func _choose(i: int) -> void:
	if i >= pending.size():
		return
	var fn = pending[i]["fn"]
	if fn is Callable:
		fn.call()
	else:
		call(fn)
	level_panel.visible = false
	get_tree().paused = false
	choosing = false
	# Trả thẻ về độ sáng bình thường và hiện lại đủ 3 thẻ cho lần mở kế tiếp
	for j in 3:
		var b: Button = level_panel.get_node("VBox/HBox/Btn%d" % (j + 1))
		b.modulate = Color.WHITE
		b.visible = true
	if xp >= xp_needed:
		_show_level_up()


# Trả về thẻ cho các mốc Đan Chéo (5/10/15/20); rỗng nếu cấp thường
func _milestone_cards(lvl: int) -> Array:
	var cards := []
	match lvl:
		5:
			var cores: Array = SIG_CORES.get(player.weapon, [])
			for cdef in cores:
				var cid := String(cdef["id"])
				cards.append({
					"label": "%s\n%s" % [cdef["name"][lang], cdef["desc"][lang]],
					"fn": func() -> void: _sig_apply_core(cid),
					"col": Color(1.0, 0.78, 0.27),
					"icon": cdef.get("icon", null),
				})
		10:
			cards.append({
				"label": T("sig_enhance_label"),
				"fn": func() -> void: _sig_enhance(),
				"col": Color(1.0, 0.55, 0.3),
				"icon": preload("res://assets/icons/sig_enhance.svg"),
			})
		15:
			for fdef in SIG_FORMS:
				var fid := String(fdef["id"])
				cards.append({
					"label": "%s\n%s" % [fdef["name"][lang], fdef["desc"][lang]],
					"fn": func() -> void: _sig_apply_form(fid),
					"col": Color(0.6, 0.45, 0.95),
					"icon": fdef.get("icon", null),
				})
		20:
			cards.append({
				"label": T("sig_ultimate_label"),
				"fn": func() -> void: _sig_ultimate(),
				"col": Color(1.0, 0.3, 0.3),
				"icon": preload("res://assets/icons/sig_ultimate.svg"),
			})
	return cards


func _sig_apply_core(id: String) -> void:
	chosen_core = id
	match id:
		"burn":      player.sig_burn = 6.0
		"pierce":    player.sig_pierce_bonus += 3; player.sig_dmg_mul *= 1.12
		"aoe":       player.sig_aoe_bonus += 35.0
		"chain":     player.sig_chain = true
		"frenzy":    _frenzy_cd = 5.0  # kích hoạt lần đầu nhanh để thấy ngay
		"explosive": player.sig_aoe_bonus += 20.0
		"wave":      player.sig_blade_wave = true
		"lifesteal": player.sig_lifesteal = 1.5


func _sig_enhance() -> void:
	# Cấp 10: cường hóa chính Lõi đã chọn ở cấp 5
	match chosen_core:
		"burn":      player.sig_burn *= 2.2
		"pierce":    player.sig_pierce_bonus += 3; player.sig_dmg_mul *= 1.15
		"aoe":       player.sig_aoe_bonus += 30.0
		"chain":     player.sig_chain = true; player.sig_aoe_bonus += 30.0
		"frenzy":    _frenzy_cd = maxf(_frenzy_cd, 1.0); _frenzy_dur = 8.0  # tăng thời lượng lên 8s
		"explosive": player.sig_aoe_bonus += 15.0; player.sig_dmg_mul *= 1.08
		"wave":      player.sig_dmg_mul *= 1.2
		"lifesteal": player.sig_lifesteal += 1.5; player.sig_dmg_mul *= 1.1
		_:           player.sig_dmg_mul *= 1.2


func _sig_apply_form(id: String) -> void:
	chosen_form = id
	match id:
		"lifedrain":    player.sig_lifedrain_on_kill = true
		"shock":        player.sig_shock = 1.2


func _sig_ultimate() -> void:
	# Cấp 20: đẩy Lõi + Hình thái lên giới hạn + dọn màn
	player.sig_dmg_mul *= 1.6
	player.fire_rate += 0.8
	_sig_enhance()  # cường hóa Lõi thêm lần nữa
	if chosen_form == "lifedrain":
		player.sig_lifedrain_on_kill = true
	elif chosen_form == "shock":
		player.sig_shock = maxf(player.sig_shock, 2.0)
	_signature_nuke()


func _signature_nuke() -> void:
	# Dọn màn: gây sát thương rất lớn cho mọi quái quanh người chơi
	var c: Vector2 = player.global_position
	for e in get_tree().get_nodes_in_group("enemies"):
		if c.distance_to(e.global_position) < 1100.0:
			e.take_hit(400.0, true, (e.global_position - c).normalized() * 520.0, Color(1.0, 0.9, 0.4), true)
	spawn_explosion(c, 1200.0, 0.8)
	player.shake_amt = 11.0


func _signature_kill_blast(pos: Vector2) -> void:
	# Hình thái "Nổ Chùm": quái chết phát nổ nhỏ (có giới hạn theo khung hình)
	var dmg: float = 2.0 + player.projectile_damage * 0.2
	for e in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(e.global_position) < 40.0:
			e.take_hit(dmg, true, (e.global_position - pos).normalized() * 80.0, Color(1.0, 0.6, 0.3))
	spawn_explosion(pos, 65.0, 0.25)


func _build_pool() -> Array:
	var pool := []
	for s in STAT_UPGRADES:
		if s["fn"] == "_up_max_hp" and randf() > 0.10:
			continue
		if s["fn"] == "_up_dmg_boost" and player.sig_dmg_mul >= 1.8:
			continue  # đã buff đủ mạnh thì ẩn đi
		pool.append({"label": s["label"][lang], "fn": s["fn"], "icon": s["icon"]})
	_add_weapon(pool, player.orbital_count, player.orbital_evolved,
		["Kiếm xoay", "Spinning swords"], "_up_orbital",
		["TIẾN HÓA ⚔ Kiếm thánh: to hơn, xoay nhanh, sát thương x2.2",
			"EVOLVE ⚔ Holy blades: bigger, faster, x2.2 damage"], "_evo_orbital", ICON_ORBITAL)
	_add_weapon(pool, player.grenade_level, player.grenade_evolved,
		["Lựu đạn nổ lan", "Grenade"], "_up_grenade",
		["TIẾN HÓA 💣 Bom chùm: nổ thêm 3 đợt phụ",
			"EVOLVE 💣 Cluster bomb: 3 extra blasts"], "_evo_grenade", ICON_GRENADE)
	_add_weapon(pool, player.lightning_level, player.lightning_evolved,
		["Sét đánh chuỗi", "Chain lightning"], "_up_lightning",
		["TIẾN HÓA ⚡ Bão sét: +3 mục tiêu, đánh nhanh gần gấp đôi",
			"EVOLVE ⚡ Lightning storm: +3 targets, near-double speed"], "_evo_lightning", ICON_LIGHTNING)
	_add_weapon(pool, player.poison_level, player.poison_evolved,
		["Vùng độc quanh người", "Poison aura"], "_up_poison",
		["TIẾN HÓA ☠ Trường độc: rộng x1.5, sát thương x2, làm chậm quái",
			"EVOLVE ☠ Toxic field: x1.5 area, x2 damage, slows enemies"], "_evo_poison", ICON_POISON)
	_add_weapon(pool, player.boomerang_level, player.boomerang_evolved,
		["Boomerang xuyên quái", "Boomerang"], "_up_boomerang",
		["TIẾN HÓA Cuồng phong: 2 boomerang to hơn, sát thương x1.6",
			"EVOLVE Whirlwind: 2 bigger boomerangs, x1.6 damage"], "_evo_boomerang", ICON_BOOMERANG)
	_add_weapon(pool, player.frost_level, player.frost_evolved,
		["Tia băng làm chậm", "Frost bolt"], "_up_frost",
		["TIẾN HÓA Bão tuyết: nổ băng diện rộng, sát thương x1.5",
			"EVOLVE Blizzard: freezing blast, x1.5 damage"], "_evo_frost", ICON_FROST)
	var avail := ARTIFACTS.filter(func(a: Dictionary) -> bool: return a["fn"] not in owned_artifacts)
	if not avail.is_empty():
		# Linh thú bay (familiar) có trọng số 3x so với các cổ vật khác
		var weighted: Array = []
		for a in avail:
			weighted.append(a)
			if a["fn"] == "_art_familiar":
				weighted.append(a)
				weighted.append(a)
		var art: Dictionary = weighted.pick_random()
		pool.append({"label": T("artifact_fmt") % [art["name"][lang], art["desc"][lang]], "fn": art["fn"], "icon": art["icon"]})
	return pool


func _art_magnet() -> void:
	owned_artifacts.append("_art_magnet")
	player.magnet_range = 240.0


func _art_phoenix() -> void:
	owned_artifacts.append("_art_phoenix")
	player.revive = true


func _art_familiar() -> void:
	owned_artifacts.append("_art_familiar")
	_spawn_familiar()


func _spawn_familiar() -> void:
	var f := Node2D.new()
	f.set_script(FAMILIAR)
	f.player = player
	add_child(f)
	f.global_position = player.global_position


func _art_regen() -> void:
	owned_artifacts.append("_art_regen")
	player.regen = 0.5


func _art_crit() -> void:
	owned_artifacts.append("_art_crit")
	player.crit_chance = 0.2


func _art_xp() -> void:
	owned_artifacts.append("_art_xp")
	xp_gain = 2


func _add_weapon(pool: Array, lvl: int, evolved: bool, name: Array, up_fn: String, evo_label: Array, evo_fn: String, icon: Texture2D) -> void:
	if lvl < WEAPON_MAX:
		pool.append({"label": T("weapon_lv") % [name[lang], lvl, lvl + 1], "fn": up_fn, "icon": icon})
	elif not evolved:
		pool.append({"label": evo_label[lang], "fn": evo_fn, "icon": icon})


func _evo_orbital() -> void:
	player.evolve_orbitals()


func _evo_grenade() -> void:
	player.grenade_evolved = true


func _evo_lightning() -> void:
	player.lightning_evolved = true


func _evo_poison() -> void:
	player.poison_evolved = true
	player.update_poison_ring()


func _up_damage() -> void:
	# "Sức Mạnh Giao Tranh": +20% sát thương cơ bản (cả đạn lẫn đòn chém)
	player.sig_dmg_mul *= 1.2


func _up_fire_rate() -> void:
	# "Nhịp Độ Tử Thần": giảm 15% thời gian hồi đòn
	player.fire_rate /= 0.85


func _up_projectile() -> void:
	# "Nhân Bản / Liên Kích": Katana chém bồi; còn lại +1 đạn
	if player.weapon == "katana":
		player.katana_combo += 1
	else:
		player.projectile_count += 1


func _up_pierce() -> void:
	# "Xuyên Thấu / Khuếch Đại": thích ứng theo loại vũ khí
	match player.weapon:
		"katana":
			player.katana_reach *= 1.15        # chém xa hơn, an toàn hơn
		"cannon":
			player.aoe_mult *= 1.15             # bán kính nổ to hơn
		_:
			player.pierce += 1                  # súng đơn: +1 xuyên


func _up_speed() -> void:
	player.speed += 25.0


func _up_max_hp() -> void:
	player.max_hp += 25.0
	player.heal(player.max_hp)


func _up_exploit() -> void:
	# "Khai Thác Điểm Yếu": +40% dmg lên quái đang dính hiệu ứng
	player.exploit_dmg += 0.4


func _up_armor() -> void:
	# "Kiên Cường": giảm 20% sát thương nhận (tối đa 75%)
	player.damage_reduction = minf(player.damage_reduction + 0.2, 0.75)


func _up_dmg_boost() -> void:
	player.sig_dmg_mul *= 1.2


func chain_react(pos: Vector2) -> void:
	# Gọi từ enemy khi crit/overkill hạ gục — nổ nhẹ, có giới hạn theo khung hình
	if _kill_blast_budget <= 0:
		return
	_kill_blast_budget -= 1
	_signature_kill_blast(pos)


func _up_orbital() -> void:
	player.add_orbital()


func _up_grenade() -> void:
	player.grenade_level += 1


func _up_lightning() -> void:
	player.lightning_level += 1


func _up_poison() -> void:
	player.poison_level += 1
	player.update_poison_ring()


func _up_boomerang() -> void:
	player.boomerang_level += 1


func _evo_boomerang() -> void:
	player.boomerang_evolved = true


func _up_frost() -> void:
	player.frost_level += 1


func _evo_frost() -> void:
	player.frost_evolved = true


func _trigger_event() -> void:
	match randi() % 3:
		0:
			_event_ring()
		1:
			_event_flood()
		2:
			_event_frenzy()


func _event_ring() -> void:
	_announce(T("ev_ring"))
	var count := 22
	for i in count:
		var e := _make_enemy()
		e.hp = 2.5 + time * 0.05
		e.speed = minf(70.0 + time * 0.6, 160.0)
		_apply_stage(e)
		add_child(e)
		e.global_position = player.global_position + Vector2.from_angle(TAU * i / count) * 650.0


func _event_flood() -> void:
	_announce(T("ev_flood"))
	var base_angle := randf() * TAU
	for i in 16:
		var e := _make_enemy()
		e.tex = TEX_HITMAN
		e.hp = (2.5 + time * 0.05) * 0.6
		e.speed = minf(130.0 + time * 0.5, 210.0)
		_apply_stage(e)
		add_child(e)
		var angle := base_angle + randf_range(-0.45, 0.45)
		e.global_position = player.global_position + Vector2.from_angle(angle) * randf_range(580.0, 760.0)


func _event_frenzy() -> void:
	_announce(T("ev_frenzy"), Color(1.0, 0.4, 0.2))
	frenzy_timer = 20.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.has_meta("fz"):
			e.speed *= 1.45
			e.set_meta("fz", true)


func _frenzy_core_tick(delta: float) -> void:
	if _frenzy_on:
		_frenzy_dur -= delta
		if _frenzy_dur <= 0.0:
			# Tắt cuồng nộ — khôi phục chỉ số gốc
			_frenzy_on = false
			if not _frenzy_backup.is_empty() and is_instance_valid(player):
				player.speed              = _frenzy_backup["speed"]
				player.fire_rate          = _frenzy_backup["fire_rate"]
				player.projectile_damage  = _frenzy_backup["dmg"]
			_frenzy_backup = {}
			_frenzy_cd = 30.0
			_announce(T("core_frenzy_off"), Color(1.0, 0.5, 0.2))
	else:
		_frenzy_cd -= delta
		if _frenzy_cd <= 0.0 and is_instance_valid(player) and player.alive:
			# Bật cuồng nộ — nhân đôi tất cả chỉ số
			_frenzy_on = true
			var dur := 6.0 if _frenzy_dur == 0.0 else _frenzy_dur
			_frenzy_dur = dur
			_frenzy_backup = {
				"speed":     player.speed,
				"fire_rate": player.fire_rate,
				"dmg":       player.projectile_damage,
			}
			player.speed             *= 2.0
			player.fire_rate         *= 2.0
			player.projectile_damage *= 2.0
			_announce(T("core_frenzy_on"), Color(1.0, 0.25, 0.1), 3.0)


func _announce(text: String, color := Color(1.0, 0.9, 0.3), shake := 0.0) -> void:
	if shake > 0.0 and is_instance_valid(player):
		player.shake_amt = maxf(player.shake_amt, shake)
	var banner := PanelContainer.new()
	banner.add_to_group("announce")
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.06, 0.09, 0.82)
	sb.border_color = color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 6.0
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 4
	banner.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", announce_font)
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", color.lerp(Color.WHITE, 0.35))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_child(l)
	$UI.add_child(banner)
	var vp := get_viewport_rect().size
	var offset_y := (get_tree().get_nodes_in_group("announce").size() - 1) * 40.0
	await get_tree().process_frame
	banner.position = Vector2(vp.x * 0.5 - banner.size.x * 0.5, vp.y * 0.20 + offset_y)
	banner.pivot_offset = banner.size * 0.5
	banner.scale = Vector2.ONE * 0.7
	banner.modulate.a = 0.0
	var tw := banner.create_tween()
	tw.set_parallel(true)
	tw.tween_property(banner, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(banner, "modulate:a", 1.0, 0.2)
	tw.set_parallel(false)
	tw.tween_interval(1.8)
	tw.tween_property(banner, "modulate:a", 0.0, 0.5)
	tw.tween_callback(banner.queue_free)


func _build_chest_panel() -> void:
	chest_panel = PanelContainer.new()
	chest_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	chest_panel.visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.08, 0.13, 0.97)
	sb.border_color = Color(1.0, 0.78, 0.25)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 36.0
	sb.content_margin_right = 36.0
	sb.content_margin_top = 24.0
	sb.content_margin_bottom = 24.0
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 12
	chest_panel.add_theme_stylebox_override("panel", sb)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	var icon := TextureRect.new()
	icon.texture = ICON_CHEST
	icon.custom_minimum_size = Vector2(72, 72)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = Color(1.0, 0.85, 0.2)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(icon)
	chest_title = Label.new()
	chest_title.add_theme_font_size_override("font_size", 32)
	chest_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	chest_title.add_theme_color_override("font_outline_color", Color(0.35, 0.2, 0.0))
	chest_title.add_theme_constant_override("outline_size", 6)
	chest_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(chest_title)
	chest_text = Label.new()
	chest_text.add_theme_font_size_override("font_size", 22)
	chest_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(chest_text)
	chest_btn = Button.new()
	chest_btn.add_theme_font_size_override("font_size", 24)
	var bb := StyleBoxFlat.new()
	bb.bg_color = Color(1.0, 0.78, 0.25)
	bb.set_corner_radius_all(10)
	bb.content_margin_left = 28.0
	bb.content_margin_right = 28.0
	bb.content_margin_top = 8.0
	bb.content_margin_bottom = 8.0
	var bh: StyleBoxFlat = bb.duplicate()
	bh.bg_color = Color(1.0, 0.88, 0.45)
	chest_btn.add_theme_stylebox_override("normal", bb)
	chest_btn.add_theme_stylebox_override("hover", bh)
	chest_btn.add_theme_stylebox_override("pressed", bb)
	chest_btn.add_theme_color_override("font_color", Color(0.2, 0.12, 0.0))
	chest_btn.add_theme_color_override("font_hover_color", Color(0.2, 0.12, 0.0))
	chest_btn.add_theme_color_override("font_pressed_color", Color(0.2, 0.12, 0.0))
	chest_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chest_btn.focus_mode = Control.FOCUS_NONE
	chest_btn.pressed.connect(_close_chest)
	vbox.add_child(chest_btn)
	chest_panel.add_child(vbox)
	$UI.add_child(chest_panel)
	chest_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	chest_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	chest_panel.grow_vertical = Control.GROW_DIRECTION_BOTH


func _build_map_panel() -> void:
	map_panel = PanelContainer.new()
	map_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	map_panel.visible = false
	map_panel.custom_minimum_size = Vector2(440, 0)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	map_title = Label.new()
	map_title.add_theme_font_size_override("font_size", 34)
	map_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(map_title)
	# Mỗi biome một màu viền: Đồng cỏ / Sa mạc / Vùng chết
	var map_accents := [
		Color(0.5, 0.9, 0.5),     # Đồng cỏ — xanh lá
		Color(1.0, 0.78, 0.4),    # Sa mạc — cát vàng
		Color(0.75, 0.55, 1.0),   # Vùng chết — tím
	]
	for i in 3:
		var b := Button.new()
		b.add_theme_font_size_override("font_size", 22)
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 64)
		b.pressed.connect(_pick_map.bind(i))
		_skin_menu_card(b, map_accents[i])
		map_btns.append(b)
		vbox.add_child(b)
	map_panel.add_child(vbox)
	$UI.add_child(map_panel)
	_skin_menu_panel(map_panel)
	_style_menu_title(map_title)
	map_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	map_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	map_panel.grow_vertical = Control.GROW_DIRECTION_BOTH


func _refresh_map_panel() -> void:
	if map_panel == null:
		return
	map_title.text = T("map_title")
	for i in 3:
		var unlocked := i < unlocked_maps
		map_btns[i].disabled = not unlocked
		if unlocked:
			map_btns[i].text = STAGES[i]["name"][lang]
		else:
			map_btns[i].text = "%s  %s" % [STAGES[i]["name"][lang], T("map_locked")]
	_update_map_highlight()


func _update_map_highlight() -> void:
	for i in 3:
		if i == _map_sel:
			map_btns[i].modulate = Color(1.35, 1.35, 1.35)
		elif i >= unlocked_maps:
			map_btns[i].modulate = Color(0.55, 0.55, 0.55)
		else:
			map_btns[i].modulate = Color(0.85, 0.85, 0.85)


func _pick_map(i: int) -> void:
	if i >= unlocked_maps:
		return
	selected_stage = i
	map_panel.visible = false
	char_panel.visible = true
	_char_sel = 0
	_update_char_highlight()


func _dead_pool_tick(delta: float) -> void:
	dead_pool_timer -= delta
	if dead_pool_timer <= 0.0:
		dead_pool_timer = randf_range(4.5, 7.0)
		_spawn_dead_pool()
	for idx in range(dead_pools.size() - 1, -1, -1):
		var p: Dictionary = dead_pools[idx]
		p["t"] -= delta
		if p["t"] <= 0.0:
			if is_instance_valid(p["node"]):
				p["node"].queue_free()
			dead_pools.remove_at(idx)
			continue
		if is_instance_valid(player) and player.alive and player.global_position.distance_to(p["pos"]) < p["radius"]:
			player.take_damage(12.0 * delta)


func _spawn_dead_pool() -> void:
	var radius := randf_range(70.0, 110.0)
	var pos := player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(140.0, 340.0)
	var spr := Sprite2D.new()
	spr.texture = CIRCLE
	spr.modulate = Color(0.35, 0.9, 0.4, 0.0)
	spr.scale = Vector2.ONE * (radius * 2.0 / CIRCLE.get_size().x)
	spr.z_index = -6
	add_child(spr)
	spr.global_position = pos
	var tw := spr.create_tween()
	tw.tween_property(spr, "modulate:a", 0.45, 0.5)
	dead_pools.append({"node": spr, "pos": pos, "radius": radius, "t": 8.0})




const TEX_RAIN_SHEET  := preload("res://assets/vfx/rain_sheet.png")
const TEX_PUDDLE      := preload("res://assets/vfx/puddle_sheet.png")
const TEX_RAIN_SPLASH := preload("res://assets/vfx/rain_splash.png")
const TEX_RAIN_CLOUD1 := preload("res://assets/vfx/rain_cloud1.png")
const TEX_RAIN_CLOUD2 := preload("res://assets/vfx/rain_cloud2.png")
const TEX_RAIN_CLOUD3 := preload("res://assets/vfx/rain_cloud3.png")

func _rain_tick(delta: float) -> void:
	# Di chuyển và scroll từng patch sương mù nhỏ
	if (_rain_active or _rain_fading) and not _rain_fog_sprs.is_empty():
		var vp := get_viewport().get_visible_rect().size
		for spr in _rain_fog_sprs:
			if not is_instance_valid(spr):
				continue
			# Drift position
			spr.position += spr.get_meta("vel") * delta
			# Wrap khi ra ngoài màn hình
			var hw: float = spr.texture.get_width() * spr.scale.x * 0.5
			var hh: float = spr.texture.get_height() * spr.scale.y * 0.5
			if spr.position.x - hw > vp.x:
				spr.position.x = -hw
			if spr.position.x + hw < 0.0:
				spr.position.x = vp.x + hw
			if spr.position.y - hh > vp.y:
				spr.position.y = -hh
			if spr.position.y + hh < 0.0:
				spr.position.y = vp.y + hh
			# Scroll texture bên trong patch
			if spr.modulate.a <= 0.0:
				continue
			var scroll: Vector2 = spr.get_meta("scroll", Vector2.ZERO) + spr.get_meta("spd") * delta
			spr.set_meta("scroll", scroll)
			(spr.material as ShaderMaterial).set_shader_parameter("u_scroll", scroll)

	if _rain_active:
		_rain_dur -= delta
		if _rain_dur <= 0.0:
			_stop_rain()
	elif not _rain_fading:
		_rain_cd -= delta
		if _rain_cd <= 0.0:
			_start_rain()


func _start_rain() -> void:
	_rain_active = true
	_rain_fading = false
	_rain_dur = randf_range(14.0, 22.0)
	_rain_cd = randf_range(35.0, 55.0)
	if is_instance_valid(player):
		_rain_speed_backup = player.speed
		player.speed *= 0.55
		_rain_slowing = true
		_rain_prev_pos = player.global_position
	var vp := get_viewport().get_visible_rect().size
	var sh := Shader.new()
	# Tiling fog + radial soft edge (elip ngang như đám mây)
	sh.code = ("shader_type canvas_item;\n"
		+ "uniform vec2 u_scroll = vec2(0.0);\n"
		+ "uniform float u_tiles = 2.0;\n"
		+ "void fragment() {\n"
		+ "\tvec2 tuv = fract(UV * u_tiles + u_scroll);\n"
		+ "\tvec4 fog = texture(TEXTURE, tuv);\n"
		+ "\tvec2 d = (UV - vec2(0.5)) * vec2(1.0, 1.9);\n"
		+ "\tfloat mask = 1.0 - smoothstep(0.32, 0.50, length(d));\n"
		+ "\tCOLOR = vec4(fog.rgb, fog.a * mask);\n"
		+ "}")
	for i in 6:
		var spr := Sprite2D.new()
		spr.texture = TEX_FOG_TILE
		spr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		# Kích thước lớn hơn, dẹt ngang như đám mây
		var sw := randf_range(0.50, 0.85)
		spr.scale = Vector2(sw * vp.x / 640.0, sw * 0.40 * vp.y / 480.0)
		spr.position = Vector2(randf() * vp.x, randf() * vp.y)
		# Tint xám xanh nhẹ
		spr.modulate = Color(0.78, 0.83, 0.92, 0.0)
		var sm := ShaderMaterial.new()
		sm.shader = sh
		sm.set_shader_parameter("u_tiles", randf_range(1.2, 2.2))
		spr.material = sm
		spr.set_meta("spd", Vector2(randf_range(0.02, 0.06), randf_range(-0.01, 0.01)))
		spr.set_meta("scroll", Vector2.ZERO)
		spr.set_meta("vel", Vector2(randf_range(15.0, 35.0), randf_range(-6.0, 6.0)))
		$UI.add_child(spr)
		$UI.move_child(spr, 0)
		var tw: Tween = create_tween()
		tw.tween_interval(float(i) * 0.6)
		tw.tween_property(spr, "modulate:a", randf_range(0.55, 0.75), randf_range(3.0, 5.0))
		_rain_fog_sprs.append(spr)


func _stop_rain() -> void:
	_rain_active = false
	_rain_fading = true
	if _rain_slowing and is_instance_valid(player):
		player.speed = _rain_speed_backup
		_rain_slowing = false
	var snap := _rain_fog_sprs.duplicate()
	for spr in snap:
		if not is_instance_valid(spr):
			continue
		var tw: Tween = create_tween()
		tw.tween_property(spr, "modulate:a", 0.0, 4.0)
	var cleanup := create_tween()
	cleanup.tween_interval(5.0)
	cleanup.tween_callback(func():
		_rain_fading = false
		for spr in snap:
			if is_instance_valid(spr):
				spr.queue_free()
		_rain_fog_sprs.clear()
	)


func _spawn_chest(pos: Vector2) -> void:
	var chest := Area2D.new()
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 22.0
	cs.shape = c
	chest.add_child(cs)
	var s := Sprite2D.new()
	s.texture = TEX_CHEST
	s.scale = Vector2(0.8, 0.8)
	chest.add_child(s)
	add_child(chest)
	chest.global_position = pos
	var tw := s.create_tween()
	tw.set_loops()
	tw.tween_property(s, "position:y", -6.0, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(s, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	chest.body_entered.connect(func(body: Node2D) -> void:
		if body == player:
			_open_chest(chest))


func _open_chest(chest: Area2D) -> void:
	chest.queue_free()
	var r := randf()
	var count := 1
	if r > 0.9:
		count = 3
	elif r > 0.6:
		count = 2
	var lines: Array[String] = []
	for i in count:
		var pool := _build_pool()
		var pick: Dictionary = pool.pick_random()
		call(pick["fn"])
		lines.append("• " + pick["label"])
	chest_text.text = "\n".join(lines)
	chest_panel.visible = true
	get_tree().paused = true


func _build_pause_panel() -> void:
	pause_panel = PanelContainer.new()
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_panel.visible = false
	pause_panel.custom_minimum_size = Vector2(300, 0)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	pause_title = Label.new()
	pause_title.add_theme_font_size_override("font_size", 32)
	pause_title.add_theme_color_override("font_color", Color(0.15, 0.17, 0.25))
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pause_title)
	pause_resume = Button.new()
	pause_resume.add_theme_font_size_override("font_size", 22)
	pause_resume.pressed.connect(_toggle_pause)
	vbox.add_child(pause_resume)
	pause_reset = Button.new()
	pause_reset.add_theme_font_size_override("font_size", 22)
	pause_reset.pressed.connect(_restart_game)
	vbox.add_child(pause_reset)
	var pl := Button.new()
	pl.text = "Tiếng Việt / English"
	pl.add_theme_font_size_override("font_size", 22)
	pl.pressed.connect(func() -> void: _set_lang(1 - lang))
	vbox.add_child(pl)
	pause_panel.add_child(vbox)
	$UI.add_child(pause_panel)
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pause_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pause_panel.grow_vertical = Control.GROW_DIRECTION_BOTH


func _toggle_pause() -> void:
	if game_over or choosing or char_panel.visible or chest_panel.visible:
		return
	pause_panel.visible = not pause_panel.visible
	get_tree().paused = pause_panel.visible


func _restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _close_chest() -> void:
	chest_panel.visible = false
	if not choosing:
		get_tree().paused = false


func _update_arrows() -> void:
	bosses = bosses.filter(func(b: Variant) -> bool: return is_instance_valid(b))
	while arrows.size() < bosses.size():
		var p := Polygon2D.new()
		p.polygon = PackedVector2Array([Vector2(16, 0), Vector2(-10, 10), Vector2(-10, -10)])
		p.color = Color(1.0, 0.25, 0.2)
		arrows_holder.add_child(p)
		arrows.append(p)
	var center := get_viewport_rect().size * 0.5
	for i in arrows.size():
		var arrow: Polygon2D = arrows[i]
		if i >= bosses.size():
			arrow.visible = false
			continue
		var to_boss: Vector2 = bosses[i].global_position - player.global_position
		if to_boss.length() <= 420.0:
			arrow.visible = false
			continue
		arrow.visible = true
		arrow.position = center + to_boss.normalized() * 250.0
		arrow.rotation = to_boss.angle()
		arrow.scale = Vector2.ONE * (1.0 + 0.2 * sin(time * 8.0))


func _on_player_died() -> void:
	game_over = true
	Engine.time_scale = 1.0  # đảm bảo không kẹt khựng khung hình khi chết
	if is_instance_valid(gate):
		gate.queue_free()
	gate = null
	# Chết = chỉ giữ 50% Vàng kiếm trong ván; Mảnh Linh Hồn không bao giờ mất
	var kept_gold := int(run_gold * 0.5)
	gold += kept_gold
	souls += run_souls
	_save_meta()
	over_label.text = (T("gameover_fmt") % [int(time) / 60, int(time) % 60, kills]) \
		+ (T("reward_fmt") % [kept_gold, run_souls]) + T("death_penalty")
	over_label.visible = true
	get_tree().paused = true  # dừng toàn bộ thế giới khi hiện menu kết thúc


func _on_restart() -> void:
	# Phím R ở màn kết thúc → bỏ pause và tải lại (về menu chọn map/nhân vật)
	if game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()


var _debug_label: Label

func _build_debug_panel() -> void:
	var panel := PanelContainer.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	var btn_minus := Button.new()
	btn_minus.text = "-"
	btn_minus.add_theme_font_size_override("font_size", 18)
	btn_minus.custom_minimum_size = Vector2(32, 0)
	btn_minus.pressed.connect(func() -> void:
		stage_len = maxf(10.0, stage_len - 10.0)
		_update_debug_label())

	_debug_label = Label.new()
	_debug_label.add_theme_font_size_override("font_size", 18)
	_debug_label.custom_minimum_size = Vector2(100, 0)
	_debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_debug_label.text = "Stage: %.0fs" % stage_len

	var btn_plus := Button.new()
	btn_plus.text = "+"
	btn_plus.add_theme_font_size_override("font_size", 18)
	btn_plus.custom_minimum_size = Vector2(32, 0)
	btn_plus.pressed.connect(func() -> void:
		stage_len += 10.0
		_update_debug_label())

	var btn_familiar := Button.new()
	btn_familiar.text = "Thú"
	btn_familiar.add_theme_font_size_override("font_size", 18)
	btn_familiar.pressed.connect(_spawn_familiar)

	var btn_reset := Button.new()
	btn_reset.text = "Reset NV"
	btn_reset.add_theme_font_size_override("font_size", 18)
	btn_reset.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	btn_reset.pressed.connect(func() -> void:
		gold = 0
		souls = 0
		meta_levels.clear()
		unlocked_maps = 1
		ronin_unlocked = false
		_save_meta()
		_refresh_shop())

	hbox.add_child(btn_minus)
	hbox.add_child(_debug_label)
	hbox.add_child(btn_plus)
	hbox.add_child(btn_familiar)
	hbox.add_child(btn_reset)
	panel.add_child(hbox)
	$UI.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.position.y -= 8
	panel.position.x += 8


func _update_debug_label() -> void:
	if _debug_label:
		_debug_label.text = "Stage: %.0fs" % stage_len
