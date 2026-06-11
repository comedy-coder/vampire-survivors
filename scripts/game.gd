extends Node2D

const ENEMY := preload("res://scripts/enemy.gd")
const GEM := preload("res://scripts/gem.gd")

const TEX_ZOMBIE := preload("res://assets/characters/zombie.png")
const TEX_HITMAN := preload("res://assets/characters/hitman.png")
const TEX_ROBOT := preload("res://assets/characters/robot.png")
const TEX_GRASS := preload("res://assets/tiles/grass_01.png")
const MUSIC := preload("res://assets/audio/music.mp3")
const SND_DIE := preload("res://assets/audio/enemy_die.ogg")
const CIRCLE := preload("res://assets/circle.svg")
const TEX_EXPLOSION := preload("res://assets/vfx/explosion_sheet.png")

const CHARACTERS := [
	{
		"tex": preload("res://assets/characters/player_blue.png"),
		"name": "Dân thường", "desc": "Cân bằng mọi mặt",
		"hp": 100.0, "speed": 220.0, "fire": 1.5, "dmg": 2.0, "count": 1, "pierce": 0,
	},
	{
		"tex": preload("res://assets/characters/player_woman.png"),
		"name": "Nữ chiến binh", "desc": "Nhanh nhẹn nhưng máu giấy",
		"hp": 75.0, "speed": 285.0, "fire": 1.8, "dmg": 1.6, "count": 1, "pierce": 0,
	},
	{
		"tex": preload("res://assets/characters/player_soldier.png"),
		"name": "Lính đặc nhiệm", "desc": "Bắn 2 viên mỗi phát",
		"hp": 100.0, "speed": 200.0, "fire": 1.3, "dmg": 1.4, "count": 2, "pierce": 0,
	},
	{
		"tex": preload("res://assets/characters/player_old.png"),
		"name": "Ông già gân", "desc": "Trâu bò nhưng chậm chạp",
		"hp": 160.0, "speed": 170.0, "fire": 1.2, "dmg": 2.4, "count": 1, "pierce": 0,
	},
	{
		"tex": preload("res://assets/characters/player_survivor.png"),
		"name": "Người sống sót", "desc": "Đạn xuyên 2 mục tiêu",
		"hp": 90.0, "speed": 230.0, "fire": 1.4, "dmg": 2.0, "count": 1, "pierce": 2,
	},
	{
		"tex": preload("res://assets/characters/player_brown.png"),
		"name": "Thợ săn", "desc": "Sát thương cực lớn, bắn chậm",
		"hp": 85.0, "speed": 225.0, "fire": 0.9, "dmg": 4.0, "count": 1, "pierce": 0,
	},
]

const BOSS_INTERVAL := 45.0

const UPGRADES := [
	{"label": "+0.6 Sát thương đạn", "fn": "_up_damage"},
	{"label": "+0.5 Tốc độ bắn", "fn": "_up_fire_rate"},
	{"label": "+1 Đạn mỗi phát", "fn": "_up_projectile"},
	{"label": "Đạn xuyên +1 mục tiêu", "fn": "_up_pierce"},
	{"label": "+25 Tốc độ chạy", "fn": "_up_speed"},
	{"label": "+25 Máu tối đa (hồi đầy)", "fn": "_up_max_hp"},
	{"label": "+1 Kiếm xoay quanh người", "fn": "_up_orbital"},
	{"label": "Lựu đạn nổ lan (+1 cấp)", "fn": "_up_grenade"},
	{"label": "Sét đánh chuỗi (+1 cấp)", "fn": "_up_lightning"},
	{"label": "Vùng độc quanh người (+1 cấp)", "fn": "_up_poison"},
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

var ground := Sprite2D.new()
var music := AudioStreamPlayer.new()
var die_sfx := AudioStreamPlayer.new()

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
	music.stream = MUSIC
	music.stream.loop = true
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
	for i in 3:
		level_panel.get_node("VBox/Btn%d" % (i + 1)).pressed.connect(_choose.bind(i))
	for i in 6:
		var btn: Button = char_panel.get_node("VBox/Grid/CharBtn%d" % (i + 1))
		var c: Dictionary = CHARACTERS[i]
		btn.text = "%s\n%s\nHP %d • Tốc %d • DMG %.1f" % [c["name"], c["desc"], int(c["hp"]), int(c["speed"]), c["dmg"]]
		btn.pressed.connect(_pick_char.bind(i))
	get_tree().paused = true


func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible


func _set_music_vol(v: float) -> void:
	music.volume_db = linear_to_db(v) if v > 0.0 else -80.0


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
	char_panel.visible = false
	get_tree().paused = false
	music.stop()


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	ground.global_position = player.global_position.snapped(Vector2(64.0, 64.0))

	time += delta
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = maxf(0.25, 1.2 - time * 0.012)
		_spawn_enemy()

	boss_timer -= delta
	if boss_timer <= 0.0:
		boss_timer = BOSS_INTERVAL
		_spawn_boss()

	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp
	hp_label.text = "HP: %d / %d" % [int(player.hp), int(player.max_hp)]
	time_label.text = "%02d:%02d" % [int(time) / 60, int(time) % 60]
	xp_bar.max_value = xp_needed
	xp_bar.value = xp
	level_label.text = "Level %d  (XP %d/%d)" % [level, xp, xp_needed]
	kills_label.text = "Kills: %d" % kills


func _make_enemy() -> Area2D:
	var e := Area2D.new()
	e.set_script(ENEMY)
	e.player = player
	e.died.connect(_on_enemy_died)
	e.summon.connect(_on_boss_summon)
	return e


func _spawn_enemy() -> void:
	var e := _make_enemy()
	var r := randf()
	if time > 60.0 and r < 0.15:
		e.tex = TEX_ROBOT
		e.hp = (3.0 + time * 0.06) * 3.0
		e.speed = 45.0
		e.dps = 25.0
		e.gems = 3
	elif time > 40.0 and r < 0.28:
		# Xạ thủ: giữ khoảng cách và bắn đạn về phía người chơi
		e.tex = TEX_HITMAN
		e.tint = Color(0.5, 1.0, 0.6)
		e.kind = ENEMY.Kind.RANGER
		e.hp = (3.0 + time * 0.06) * 0.9
		e.speed = 85.0
		e.bullet_damage = 8.0
		e.gems = 2
	elif time > 30.0 and r < 0.45:
		e.tex = TEX_HITMAN
		e.hp = (3.0 + time * 0.06) * 0.6
		e.speed = minf(110.0 + time * 0.5, 200.0)
		e.gems = 1
	else:
		e.hp = 3.0 + time * 0.06
		e.speed = minf(60.0 + time * 0.6, 150.0)
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 550.0


func _spawn_boss() -> void:
	boss_count += 1
	var e := _make_enemy()
	e.kind = ENEMY.Kind.BOSS
	e.sprite_scale = 1.5
	e.hp = 50.0 + time * 1.5
	e.dps = 30.0
	e.gems = 8
	if boss_count % 2 == 1:
		# Zombie chúa: nhấp nháy đỏ rồi lao thẳng vào người chơi, biết gọi đệ
		e.tex = TEX_ZOMBIE
		e.tint = Color(1.0, 0.5, 0.5)
		e.speed = 70.0
		e.skills = ["dash", "dash", "summon"]
	else:
		# Robot pháo đài: bắn vòng đạn toả tròn, biết gọi đệ
		e.tex = TEX_ROBOT
		e.tint = Color(0.8, 0.6, 1.0)
		e.speed = 55.0
		e.bullet_damage = 10.0
		e.skills = ["burst", "burst", "summon"]
		e.skill_interval = 5.0
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 600.0


func _on_boss_summon(pos: Vector2) -> void:
	spawn_explosion(pos, 110.0, 0.4)
	for i in 4:
		var e := _make_enemy()
		e.tint = Color(0.7, 1.0, 0.7)
		e.sprite_scale = 0.6
		e.hp = (3.0 + time * 0.06) * 0.7
		e.speed = minf(75.0 + time * 0.6, 165.0)
		e.gems = 1
		add_child(e)
		e.global_position = pos + Vector2.from_angle(TAU * i / 4.0 + randf() * 0.5) * 60.0


func _on_enemy_died(pos: Vector2, gem_count: int) -> void:
	kills += 1
	_spawn_death_fx(pos)
	die_sfx.pitch_scale = randf_range(0.85, 1.15)
	die_sfx.play()
	for i in gem_count:
		var g := Area2D.new()
		g.set_script(GEM)
		g.player = player
		g.collected.connect(_on_gem_collected)
		add_child(g)
		g.global_position = pos + Vector2.from_angle(randf() * TAU) * (randf() * 20.0)


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


func _on_gem_collected() -> void:
	xp += 1
	if xp >= xp_needed and not choosing:
		_show_level_up()


func _show_level_up() -> void:
	choosing = true
	xp -= xp_needed
	xp_needed = int(xp_needed * 1.4) + 2
	level += 1
	player.heal(20.0)

	var pool := UPGRADES.duplicate()
	pool.shuffle()
	pending = pool.slice(0, 3)
	for i in 3:
		level_panel.get_node("VBox/Btn%d" % (i + 1)).text = pending[i]["label"]

	level_panel.visible = true
	get_tree().paused = true


func _choose(i: int) -> void:
	call(pending[i]["fn"])
	level_panel.visible = false
	get_tree().paused = false
	choosing = false
	if xp >= xp_needed:
		_show_level_up()


func _up_damage() -> void:
	player.projectile_damage += 0.6


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


func _on_player_died() -> void:
	game_over = true
	over_label.text = "GAME OVER\nSống sót: %02d:%02d — %d kills\nNhấn R để chơi lại" % [int(time) / 60, int(time) % 60, kills]
	over_label.visible = true
