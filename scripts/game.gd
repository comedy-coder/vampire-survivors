extends Node2D

const ENEMY := preload("res://scripts/enemy.gd")
const GEM := preload("res://scripts/gem.gd")
const TORNADO := preload("res://scripts/tornado.gd")
const QUICKSAND := preload("res://scripts/quicksand.gd")
const PICKUP := preload("res://scripts/pickup.gd")
const CRATE := preload("res://scripts/crate.gd")
const FAMILIAR := preload("res://scripts/familiar.gd")

const ICON_PICK_HEAL := preload("res://assets/icons/up_hp.svg")
const ICON_PICK_MAGNET := preload("res://assets/icons/art_magnet.svg")
const ICON_PICK_BOMB := preload("res://assets/icons/w_grenade.svg")

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
	"levelup_title": ["LEVEL UP! Chọn nâng cấp", "LEVEL UP! Choose an upgrade"],
	"char_title": ["CHỌN NHÂN VẬT", "CHOOSE YOUR CHARACTER"],
	"sound_title": ["ÂM THANH", "SOUND"],
	"music": ["Nhạc nền", "Music"],
	"sfx": ["Tiếng súng", "Sound FX"],
	"close": ["Đóng", "Close"],
	"chest_title": ["RƯƠNG BÁU VẬT!", "TREASURE CHEST!"],
	"chest_take": ["Nhận!", "Take!"],
	"pause_title": ["TẠM DỪNG", "PAUSED"],
	"resume": ["Tiếp tục", "Resume"],
	"reselect": ["Chọn lại nhân vật", "Change character"],
	"lang_label": ["Ngôn ngữ:", "Language:"],
	"boss_announce": ["BOSS XUẤT HIỆN!", "BOSS INCOMING!"],
	"boss_desert": ["HUNG THẦN SA MẠC!", "DESERT FIEND!"],
	"boss_dead":  ["CHÚA TỂ XƯƠNG!", "BONE LORD!"],
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
	"shop_btn": ["🛒 Nâng cấp (Vàng: %d)", "🛒 Upgrades (Gold: %d)"],
	"shop_title": ["NÂNG CẤP VĨNH VIỄN", "PERMANENT UPGRADES"],
	"shop_gold": ["💰 Vàng: %d", "💰 Gold: %d"],
	"shop_close": ["← Quay lại", "← Back"],
	"shop_buy": ["%s  (Cấp %d/%d)\n%s — Giá %d 💰", "%s  (Lv %d/%d)\n%s — Cost %d 💰"],
	"shop_max": ["%s  (TỐI ĐA)\n%s", "%s  (MAX)\n%s"],
	"gold_reward": ["\nVàng nhận: +%d   (Tổng: %d)", "\nGold earned: +%d   (Total: %d)"],
}

const CHARACTERS := [
	{
		"tex": preload("res://assets/characters/player_blue.png"),
		"name": ["Dân thường", "Commoner"],
		"desc": ["Súng lục — cân bằng mọi mặt", "Pistol — balanced all around"],
		"hp": 100.0, "speed": 220.0, "fire": 1.5, "dmg": 2.8, "count": 1, "pierce": 0,
		"weapon": "pistol",
	},
	{
		"tex": preload("res://assets/characters/player_woman.png"),
		"name": ["Nữ chiến binh", "Warrior Woman"],
		"desc": ["Tiểu liên — bắn cực nhanh, máu giấy", "SMG — blazing fire rate, fragile"],
		"hp": 75.0, "speed": 285.0, "fire": 3.0, "dmg": 1.4, "count": 1, "pierce": 0,
		"weapon": "smg",
	},
	{
		"tex": preload("res://assets/characters/player_soldier.png"),
		"name": ["Lính đặc nhiệm", "Commando"],
		"desc": ["Shotgun — tỏa 5 viên cận chiến", "Shotgun — 5-pellet close-range spread"],
		"hp": 100.0, "speed": 200.0, "fire": 1.1, "dmg": 2.2, "count": 1, "pierce": 0,
		"weapon": "shotgun",
	},
	{
		"tex": preload("res://assets/characters/player_old.png"),
		"name": ["Ông già gân", "Tough Grandpa"],
		"desc": ["Pháo — đạn nổ diện rộng, chậm chạp", "Cannon — explosive AoE shells, slow"],
		"hp": 160.0, "speed": 170.0, "fire": 0.8, "dmg": 6.5, "count": 1, "pierce": 0,
		"weapon": "cannon",
	},
	{
		"tex": preload("res://assets/characters/player_survivor.png"),
		"name": ["Người sống sót", "Survivor"],
		"desc": ["Laser — đạn xuyên thấu nhiều mục tiêu", "Laser — piercing beam shots"],
		"hp": 90.0, "speed": 230.0, "fire": 1.4, "dmg": 2.8, "count": 1, "pierce": 2,
		"weapon": "laser",
	},
	{
		"tex": preload("res://assets/characters/player_brown.png"),
		"name": ["Thợ săn", "Hunter"],
		"desc": ["Bắn tỉa — sát thương cực lớn, đạn cực nhanh", "Sniper — huge damage, ultra-fast bullets"],
		"hp": 85.0, "speed": 225.0, "fire": 0.9, "dmg": 5.5, "count": 1, "pierce": 0,
		"weapon": "sniper",
	},
]

const BOSS_INTERVAL := 45.0

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

const STAT_UPGRADES := [
	{"label": ["+0.6 Sát thương đạn", "+0.6 Bullet damage"], "fn": "_up_damage", "icon": preload("res://assets/icons/up_damage.svg")},
	{"label": ["+0.5 Tốc độ bắn", "+0.5 Fire rate"], "fn": "_up_fire_rate", "icon": preload("res://assets/icons/up_fire_rate.svg")},
	{"label": ["+1 Đạn mỗi phát", "+1 Projectile per shot"], "fn": "_up_projectile", "icon": preload("res://assets/icons/up_projectile.svg")},
	{"label": ["Đạn xuyên +1 mục tiêu", "Bullets pierce +1 enemy"], "fn": "_up_pierce", "icon": preload("res://assets/icons/up_pierce.svg")},
	{"label": ["+25 Tốc độ chạy", "+25 Move speed"], "fn": "_up_speed", "icon": preload("res://assets/icons/up_speed.svg")},
	{"label": ["+25 Máu tối đa (hồi đầy)", "+25 Max HP (full heal)"], "fn": "_up_max_hp", "icon": preload("res://assets/icons/up_hp.svg")},
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
const META_UPGRADES := [
	{"id": "hp",     "name": ["Máu tối đa", "Max HP"],         "prop": "max_hp",            "amount": 20.0, "unit": "+20 HP",   "max": 8, "base": 40},
	{"id": "dmg",    "name": ["Sát thương", "Damage"],          "prop": "projectile_damage", "amount": 0.4,  "unit": "+0.4 DMG", "max": 8, "base": 50},
	{"id": "fire",   "name": ["Tốc độ bắn", "Fire rate"],       "prop": "fire_rate",         "amount": 0.15, "unit": "+0.15",    "max": 6, "base": 50},
	{"id": "speed",  "name": ["Tốc độ chạy", "Move speed"],     "prop": "speed",             "amount": 12.0, "unit": "+12",      "max": 6, "base": 40},
	{"id": "magnet", "name": ["Tầm hút gem", "Magnet range"],   "prop": "magnet_range",      "amount": 35.0, "unit": "+35",      "max": 4, "base": 30},
	{"id": "crit",   "name": ["Tỉ lệ chí mạng", "Crit chance"], "prop": "crit_chance",       "amount": 0.03, "unit": "+3%",      "max": 5, "base": 70},
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
var gold := 0
var meta_levels := {}  # id nâng cấp -> cấp đã mua
var difficulty := 1.0      # nhân máu quái theo số nâng cấp vĩnh viễn đã mua
var enemy_dmg_mult := 1.0  # nhân sát thương quái theo số nâng cấp đã mua
var shop_panel: PanelContainer
var shop_title: Label
var shop_gold_label: Label
var shop_close: Button
var shop_open_btn: Button
var shop_rows: Array = []  # mỗi phần tử: {id, btn}
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
	for i in 3:
		level_panel.get_node("VBox/HBox/Btn%d" % (i + 1)).pressed.connect(_choose.bind(i))
	for i in 6:
		char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1)).pressed.connect(_pick_char.bind(i))
	_load_lang()
	_load_meta()
	_build_lang_row()
	_build_shop_panel()
	_build_shop_button()
	_apply_lang()
	_skin_levelup()
	_build_debug_panel()
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
	for u in META_UPGRADES:
		meta_levels[u["id"]] = int(cf.get_value("upgrades", u["id"], 0))


func _save_meta() -> void:
	var cf := ConfigFile.new()
	cf.set_value("meta", "gold", gold)
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
	difficulty = 1.0 + total * 0.04       # +4% máu quái mỗi cấp
	enemy_dmg_mult = 1.0 + total * 0.02   # +2% sát thương quái mỗi cấp


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
	shop_panel.custom_minimum_size = Vector2(560, 0)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	shop_title = Label.new()
	shop_title.add_theme_font_size_override("font_size", 30)
	shop_title.add_theme_color_override("font_color", Color(0.15, 0.17, 0.25))
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(shop_title)
	shop_gold_label = Label.new()
	shop_gold_label.add_theme_font_size_override("font_size", 24)
	shop_gold_label.add_theme_color_override("font_color", Color(0.85, 0.6, 0.05))
	shop_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(shop_gold_label)
	for u in META_UPGRADES:
		var b := Button.new()
		b.add_theme_font_size_override("font_size", 18)
		b.custom_minimum_size = Vector2(0, 52)
		b.pressed.connect(_buy_upgrade.bind(String(u["id"])))
		vbox.add_child(b)
		shop_rows.append({"id": u["id"], "btn": b})
	shop_close = Button.new()
	shop_close.add_theme_font_size_override("font_size", 22)
	shop_close.pressed.connect(_close_shop)
	vbox.add_child(shop_close)
	shop_panel.add_child(vbox)
	$UI.add_child(shop_panel)
	shop_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	shop_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	shop_panel.grow_vertical = Control.GROW_DIRECTION_BOTH


func _build_shop_button() -> void:
	shop_open_btn = Button.new()
	shop_open_btn.add_theme_font_size_override("font_size", 20)
	shop_open_btn.pressed.connect(_open_shop)
	char_panel.get_node("VBox").add_child(shop_open_btn)


func _open_shop() -> void:
	char_panel.visible = false
	_refresh_shop()
	shop_panel.visible = true


func _close_shop() -> void:
	shop_panel.visible = false
	char_panel.visible = true
	_update_shop_btn_label()


func _buy_upgrade(id: String) -> void:
	var u := _meta_by_id(id)
	var lvl := int(meta_levels.get(id, 0))
	if lvl >= int(u["max"]):
		return
	var cost := _upgrade_cost(u, lvl)
	if gold < cost:
		return
	gold -= cost
	meta_levels[id] = lvl + 1
	_save_meta()
	_refresh_shop()


func _refresh_shop() -> void:
	if shop_gold_label == null:
		return
	shop_gold_label.text = T("shop_gold") % gold
	for row in shop_rows:
		var u := _meta_by_id(String(row["id"]))
		var lvl := int(meta_levels.get(u["id"], 0))
		var b: Button = row["btn"]
		if lvl >= int(u["max"]):
			b.text = T("shop_max") % [u["name"][lang], u["unit"]]
			b.disabled = true
		else:
			var cost := _upgrade_cost(u, lvl)
			b.text = T("shop_buy") % [u["name"][lang], lvl, int(u["max"]), u["unit"], cost]
			b.disabled = gold < cost
	_update_shop_btn_label()


func _update_shop_btn_label() -> void:
	if shop_open_btn:
		shop_open_btn.text = T("shop_btn") % gold


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
	for i in 6:
		var btn: Button = char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1))
		var c: Dictionary = CHARACTERS[i]
		btn.text = "%s\n%s\n%s" % [c["name"][lang], c["desc"][lang],
			T("char_stats") % [int(c["hp"]), int(c["speed"]), c["dmg"]]]


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
	music.stream = MUSIC_GAME
	_set_music_vol(music_slider.value)
	music.play()


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	ground.global_position = player.global_position.snapped(Vector2(64.0, 64.0))
	_update_decor()

	time += delta
	_update_stage()
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = maxf(0.22, 0.9 - time * 0.015)
		_spawn_enemy()

	boss_timer -= delta
	if boss_timer <= 0.0:
		boss_timer = BOSS_INTERVAL
		_spawn_boss()

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

	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	hp_label.text = T("hp_fmt") % [int(player.hp), int(player.max_hp)]
	time_label.text = "%02d:%02d" % [int(time) / 60, int(time) % 60]
	xp_bar.max_value = xp_needed
	xp_bar.value = xp
	level_label.text = T("level_fmt") % [level, xp, xp_needed]
	kills_label.text = T("kills_fmt") % kills


func _update_stage() -> void:
	# Lặp vòng cả 3 vùng: Đồng cỏ → Sa mạc → Đất chết → Đồng cỏ ...
	var s := int(time / stage_len) % 3
	if s == stage:
		return
	stage = s
	var cfg: Dictionary = STAGES[s]
	ground.texture = cfg["tile"]
	ground.modulate = cfg["tile_mod"]
	for cell in decor_cells.keys():
		decor_cells[cell].queue_free()
	decor_cells.clear()
	_update_decor()
	if stage not in stages_announced:
		stages_announced.append(stage)
		_announce(T("stage_fmt") % cfg["name"][lang], Color(0.55, 1.0, 0.75))
	boss_timer = 12.0
	match s:
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
		e.hp = (2.5 + time * 0.05) * 3.0
		e.speed = 45.0
		e.dps = 25.0
		e.gems = 3
	elif time > 28.0 and r < 0.28:
		# Xạ thủ: giữ khoảng cách và bắn đạn về phía người chơi
		e.tex = TEX_HITMAN
		e.tint = Color(0.5, 1.0, 0.6)
		e.kind = ENEMY.Kind.RANGER
		e.hp = (2.5 + time * 0.05) * 0.9
		e.speed = 90.0
		e.bullet_damage = 8.0
		e.gems = 2
	elif time > 18.0 and r < 0.45:
		e.tex = TEX_HITMAN
		e.hp = (2.5 + time * 0.05) * 0.6
		e.speed = minf(120.0 + time * 0.5, 210.0)
		e.gems = 1
	else:
		e.hp = 2.5 + time * 0.05
		e.speed = minf(75.0 + time * 0.6, 160.0)
	if time > 45.0 and e.kind == ENEMY.Kind.MELEE and randf() < 0.06:
		_make_elite(e)
	_apply_stage(e)
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 550.0
	if frenzy_timer > 0.0:
		e.speed *= 1.45
		e.set_meta("fz", true)


func _spawn_boss() -> void:
	boss_count += 1
	var e := _make_enemy()
	e.kind = ENEMY.Kind.BOSS
	e.sprite_scale = 1.5
	e.hp = 40.0 + time * 1.2
	e.dps = 30.0
	e.gems = 8
	var announce := T("boss_announce")
	# Vùng có boss riêng (sa mạc/đất chết) thì ~50% ra boss đặc trưng, còn lại ra quái tổng hợp
	var themed := stage != 0 and randf() < 0.5
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
		announce = _apply_topdown_boss(e)
	_apply_stage(e)
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 600.0
	bosses.append(e)
	e.died.connect(func(pos: Vector2, _g: int) -> void: _spawn_chest(pos))
	_announce(announce, Color(1.0, 0.2, 0.2), 8.0)


func _apply_topdown_boss(e: Area2D) -> String:
	# Boss gắn cờ "meadow_only" chỉ được chọn khi đang ở Đồng cỏ (stage 0)
	var pool: Array = TOPDOWN_BOSSES.filter(func(b: Dictionary) -> bool: return stage == 0 or not b.get("meadow_only", false))
	var m: Dictionary = pool[boss_count % pool.size()]
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


func _on_enemy_died(pos: Vector2, gem_count: int) -> void:
	kills += 1
	_spawn_death_fx(pos)
	die_sfx.pitch_scale = randf_range(0.85, 1.15)
	die_sfx.play()
	for i in gem_count:
		_spawn_gem(pos)
	if randf() < 0.008:
		_spawn_pickup(pos)


func _spawn_gem(pos: Vector2, value := 1) -> void:
	var g := Area2D.new()
	g.set_script(GEM)
	g.player = player
	g.value = value
	g.collected.connect(_on_gem_collected)
	add_child(g)
	g.global_position = pos + Vector2.from_angle(randf() * TAU) * (randf() * 20.0)


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
		player.shake_amt = maxf(player.shake_amt, 6.0)
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
			player.shake_amt = 14.0


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


func _show_level_up() -> void:
	choosing = true
	xp -= xp_needed
	xp_needed = int(xp_needed * 1.4) + 2
	level += 1
	player.heal(20.0)

	var pool := _build_pool()
	pool.shuffle()
	pending = pool.slice(0, 3)
	for i in 3:
		var b: Button = level_panel.get_node("VBox/HBox/Btn%d" % (i + 1))
		var fn := String(pending[i]["fn"])
		var col := Color(0.5, 1.0, 0.6)  # chỉ số: xanh lá
		if fn.begins_with("_art"):
			col = Color(1.0, 0.78, 0.27)  # cổ vật: hổ phách
		elif fn.begins_with("_evo"):
			col = Color(1.0, 0.4, 0.4)  # tiến hóa: đỏ
		b.get_node("V/Text").text = pending[i]["label"]
		var icon: TextureRect = b.get_node("V/Icon")
		icon.texture = pending[i].get("icon")
		icon.modulate = col
		if i < card_frames.size():
			card_frames[i].self_modulate = col

	level_panel.visible = true
	get_tree().paused = true


func _choose(i: int) -> void:
	call(pending[i]["fn"])
	level_panel.visible = false
	get_tree().paused = false
	choosing = false
	if xp >= xp_needed:
		_show_level_up()


func _build_pool() -> Array:
	var pool := []
	for s in STAT_UPGRADES:
		if s["fn"] == "_up_max_hp" and randf() > 0.10:
			continue
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
	player.projectile_damage += 0.8


func _up_fire_rate() -> void:
	player.fire_rate += 0.5


func _up_projectile() -> void:
	player.projectile_count += 1


func _up_pierce() -> void:
	player.pierce += 1


func _up_speed() -> void:
	player.speed += 25.0


func _up_max_hp() -> void:
	player.max_hp += 25.0
	player.heal(player.max_hp)


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
	chest_btn.pressed.connect(_close_chest)
	vbox.add_child(chest_btn)
	chest_panel.add_child(vbox)
	$UI.add_child(chest_panel)
	chest_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	chest_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	chest_panel.grow_vertical = Control.GROW_DIRECTION_BOTH


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
	var reward := int((kills + boss_count * 20 + int(time / 5.0)) * 0.5)
	gold += reward
	_save_meta()
	over_label.text = (T("gameover_fmt") % [int(time) / 60, int(time) % 60, kills]) \
		+ (T("gold_reward") % [reward, gold])
	over_label.visible = true


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

	hbox.add_child(btn_minus)
	hbox.add_child(_debug_label)
	hbox.add_child(btn_plus)
	hbox.add_child(btn_familiar)
	panel.add_child(hbox)
	$UI.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.position.y -= 8
	panel.position.x += 8


func _update_debug_label() -> void:
	if _debug_label:
		_debug_label.text = "Stage: %.0fs" % stage_len
