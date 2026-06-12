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
const TEX_CHEST := preload("res://assets/decor/chest.png")

const CHARACTERS := [
	{
		"tex": preload("res://assets/characters/player_blue.png"),
		"name": "Dân thường", "desc": "Súng lục — cân bằng mọi mặt",
		"hp": 100.0, "speed": 220.0, "fire": 1.5, "dmg": 2.0, "count": 1, "pierce": 0,
		"weapon": "pistol",
	},
	{
		"tex": preload("res://assets/characters/player_woman.png"),
		"name": "Nữ chiến binh", "desc": "Tiểu liên — bắn cực nhanh, máu giấy",
		"hp": 75.0, "speed": 285.0, "fire": 3.0, "dmg": 1.0, "count": 1, "pierce": 0,
		"weapon": "smg",
	},
	{
		"tex": preload("res://assets/characters/player_soldier.png"),
		"name": "Lính đặc nhiệm", "desc": "Shotgun — tỏa 5 viên cận chiến",
		"hp": 100.0, "speed": 200.0, "fire": 1.1, "dmg": 1.6, "count": 1, "pierce": 0,
		"weapon": "shotgun",
	},
	{
		"tex": preload("res://assets/characters/player_old.png"),
		"name": "Ông già gân", "desc": "Pháo — đạn nổ diện rộng, chậm chạp",
		"hp": 160.0, "speed": 170.0, "fire": 0.8, "dmg": 5.0, "count": 1, "pierce": 0,
		"weapon": "cannon",
	},
	{
		"tex": preload("res://assets/characters/player_survivor.png"),
		"name": "Người sống sót", "desc": "Laser — đạn xuyên thấu nhiều mục tiêu",
		"hp": 90.0, "speed": 230.0, "fire": 1.4, "dmg": 2.0, "count": 1, "pierce": 2,
		"weapon": "laser",
	},
	{
		"tex": preload("res://assets/characters/player_brown.png"),
		"name": "Thợ săn", "desc": "Bắn tỉa — sát thương cực lớn, đạn cực nhanh",
		"hp": 85.0, "speed": 225.0, "fire": 0.9, "dmg": 4.0, "count": 1, "pierce": 0,
		"weapon": "sniper",
	},
]

const BOSS_INTERVAL := 45.0

const DECOR := [
	preload("res://assets/decor/grass_tuft.png"),
	preload("res://assets/decor/grass_tuft.png"),
	preload("res://assets/decor/grass_tuft.png"),
	preload("res://assets/decor/plant.png"),
	preload("res://assets/decor/plant.png"),
	preload("res://assets/decor/bush_green.png"),
	preload("res://assets/decor/bush_small.png"),
	preload("res://assets/decor/bush_orange.png"),
	preload("res://assets/decor/rock_1.png"),
	preload("res://assets/decor/rock_2.png"),
]
const DECOR_CELL := 220.0

const WEAPON_MAX := 4

const STAT_UPGRADES := [
	{"label": "+0.6 Sát thương đạn", "fn": "_up_damage", "icon": preload("res://assets/icons/up_damage.svg")},
	{"label": "+0.5 Tốc độ bắn", "fn": "_up_fire_rate", "icon": preload("res://assets/icons/up_fire_rate.svg")},
	{"label": "+1 Đạn mỗi phát", "fn": "_up_projectile", "icon": preload("res://assets/icons/up_projectile.svg")},
	{"label": "Đạn xuyên +1 mục tiêu", "fn": "_up_pierce", "icon": preload("res://assets/icons/up_pierce.svg")},
	{"label": "+25 Tốc độ chạy", "fn": "_up_speed", "icon": preload("res://assets/icons/up_speed.svg")},
	{"label": "+25 Máu tối đa (hồi đầy)", "fn": "_up_max_hp", "icon": preload("res://assets/icons/up_hp.svg")},
]

const ICON_ORBITAL := preload("res://assets/icons/w_orbital.svg")
const ICON_GRENADE := preload("res://assets/icons/w_grenade.svg")
const ICON_LIGHTNING := preload("res://assets/icons/w_lightning.svg")
const ICON_POISON := preload("res://assets/icons/w_poison.svg")

const ARTIFACTS := [
	{"name": "Nam châm cổ", "desc": "Hút gem từ xa gấp 3 lần", "fn": "_art_magnet", "icon": preload("res://assets/icons/art_magnet.svg")},
	{"name": "Tim phượng hoàng", "desc": "Hồi sinh 1 lần với nửa máu, nổ đẩy lùi quái", "fn": "_art_phoenix", "icon": preload("res://assets/icons/art_phoenix.svg")},
	{"name": "Giáp gai", "desc": "Quái chạm vào người sẽ bị thương", "fn": "_art_thorns", "icon": preload("res://assets/icons/art_thorns.svg")},
	{"name": "Bùa tái sinh", "desc": "Hồi 2 máu mỗi giây", "fn": "_art_regen", "icon": preload("res://assets/icons/art_regen.svg")},
	{"name": "Kính ngắm cổ", "desc": "20% đạn chí mạng, sát thương x2", "fn": "_art_crit", "icon": preload("res://assets/icons/art_crit.svg")},
	{"name": "Ngọc kinh nghiệm", "desc": "Mỗi gem cho gấp đôi XP", "fn": "_art_xp", "icon": preload("res://assets/icons/art_xp.svg")},
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
var decor_cells := {}
var event_timer := 75.0
var frenzy_timer := 0.0
var bosses: Array = []
var arrows: Array = []
var arrows_holder := Node2D.new()
var chest_panel: PanelContainer
var chest_text: Label
var pause_panel: PanelContainer
var owned_artifacts: Array = []
var xp_gain := 1

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
	player.weapon = c["weapon"]
	char_panel.visible = false
	get_tree().paused = false
	music.stop()


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	ground.global_position = player.global_position.snapped(Vector2(64.0, 64.0))
	_update_decor()

	time += delta
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = maxf(0.25, 1.2 - time * 0.012)
		_spawn_enemy()

	boss_timer -= delta
	if boss_timer <= 0.0:
		boss_timer = BOSS_INTERVAL
		_spawn_boss()

	event_timer -= delta
	if event_timer <= 0.0:
		event_timer = randf_range(100.0, 140.0)
		_trigger_event()

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
	hp_label.text = "HP: %d / %d" % [int(player.hp), int(player.max_hp)]
	time_label.text = "%02d:%02d" % [int(time) / 60, int(time) % 60]
	xp_bar.max_value = xp_needed
	xp_bar.value = xp
	level_label.text = "Level %d  (XP %d/%d)" % [level, xp, xp_needed]
	kills_label.text = "Kills: %d" % kills


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
	add_child(holder)
	for i in rng.randi_range(1, 3):
		var s := Sprite2D.new()
		s.texture = DECOR[rng.randi_range(0, DECOR.size() - 1)]
		s.position = Vector2(cell) * DECOR_CELL + Vector2(rng.randf_range(20.0, DECOR_CELL - 20.0), rng.randf_range(20.0, DECOR_CELL - 20.0))
		s.rotation = rng.randf_range(-0.4, 0.4)
		s.scale = Vector2.ONE * rng.randf_range(0.6, 1.0)
		holder.add_child(s)
	return holder


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
	if frenzy_timer > 0.0:
		e.speed *= 1.45
		e.set_meta("fz", true)


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
	bosses.append(e)
	e.died.connect(func(pos: Vector2, _g: int) -> void: _spawn_chest(pos))
	_announce("BOSS XUẤT HIỆN!", Color(1.0, 0.2, 0.2))


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
	xp += xp_gain
	if xp >= xp_needed and not choosing:
		_show_level_up()


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
		var col := Color.WHITE
		if fn.begins_with("_art"):
			col = Color(1.0, 0.85, 0.35)
		elif fn.begins_with("_evo"):
			col = Color(1.0, 0.5, 0.9)
		b.get_node("V/Text").text = pending[i]["label"]
		var icon: TextureRect = b.get_node("V/Icon")
		icon.texture = pending[i].get("icon")
		icon.modulate = col

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
	var pool := STAT_UPGRADES.duplicate()
	_add_weapon(pool, player.orbital_count, player.orbital_evolved,
		"Kiếm xoay", "_up_orbital", "TIẾN HÓA ⚔ Kiếm thánh: to hơn, xoay nhanh, sát thương x2.2", "_evo_orbital", ICON_ORBITAL)
	_add_weapon(pool, player.grenade_level, player.grenade_evolved,
		"Lựu đạn nổ lan", "_up_grenade", "TIẾN HÓA 💣 Bom chùm: nổ thêm 3 đợt phụ", "_evo_grenade", ICON_GRENADE)
	_add_weapon(pool, player.lightning_level, player.lightning_evolved,
		"Sét đánh chuỗi", "_up_lightning", "TIẾN HÓA ⚡ Bão sét: +3 mục tiêu, đánh nhanh gần gấp đôi", "_evo_lightning", ICON_LIGHTNING)
	_add_weapon(pool, player.poison_level, player.poison_evolved,
		"Vùng độc quanh người", "_up_poison", "TIẾN HÓA ☠ Trường độc: rộng x1.5, sát thương x2, làm chậm quái", "_evo_poison", ICON_POISON)
	var avail := ARTIFACTS.filter(func(a: Dictionary) -> bool: return a["fn"] not in owned_artifacts)
	if not avail.is_empty():
		var art: Dictionary = avail.pick_random()
		pool.append({"label": "CỔ VẬT: %s\n%s" % [art["name"], art["desc"]], "fn": art["fn"], "icon": art["icon"]})
	return pool


func _art_magnet() -> void:
	owned_artifacts.append("_art_magnet")
	player.magnet_range = 240.0


func _art_phoenix() -> void:
	owned_artifacts.append("_art_phoenix")
	player.revive = true


func _art_thorns() -> void:
	owned_artifacts.append("_art_thorns")
	player.thorns = 12.0


func _art_regen() -> void:
	owned_artifacts.append("_art_regen")
	player.regen = 2.0


func _art_crit() -> void:
	owned_artifacts.append("_art_crit")
	player.crit_chance = 0.2


func _art_xp() -> void:
	owned_artifacts.append("_art_xp")
	xp_gain = 2


func _add_weapon(pool: Array, lvl: int, evolved: bool, name: String, up_fn: String, evo_label: String, evo_fn: String, icon: Texture2D) -> void:
	if lvl < WEAPON_MAX:
		pool.append({"label": "%s (Cấp %d → %d)" % [name, lvl, lvl + 1], "fn": up_fn, "icon": icon})
	elif not evolved:
		pool.append({"label": evo_label, "fn": evo_fn, "icon": icon})


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


func _trigger_event() -> void:
	match randi() % 3:
		0:
			_event_ring()
		1:
			_event_flood()
		2:
			_event_frenzy()


func _event_ring() -> void:
	_announce("BẦY QUÁI VÂY QUANH!")
	var count := 22
	for i in count:
		var e := _make_enemy()
		e.hp = 3.0 + time * 0.06
		e.speed = minf(70.0 + time * 0.6, 160.0)
		add_child(e)
		e.global_position = player.global_position + Vector2.from_angle(TAU * i / count) * 650.0


func _event_flood() -> void:
	_announce("QUÁI TRÀN TỚI!")
	var base_angle := randf() * TAU
	for i in 16:
		var e := _make_enemy()
		e.tex = TEX_HITMAN
		e.hp = (3.0 + time * 0.06) * 0.6
		e.speed = minf(130.0 + time * 0.5, 210.0)
		add_child(e)
		var angle := base_angle + randf_range(-0.45, 0.45)
		e.global_position = player.global_position + Vector2.from_angle(angle) * randf_range(580.0, 760.0)


func _event_frenzy() -> void:
	_announce("PHÚT CUỒNG NỘ!", Color(1.0, 0.4, 0.2))
	frenzy_timer = 20.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.has_meta("fz"):
			e.speed *= 1.45
			e.set_meta("fz", true)


func _announce(text: String, color := Color(1.0, 0.9, 0.3)) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 44)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 10)
	$UI.add_child(l)
	var vp := get_viewport_rect().size
	l.position = Vector2(vp.x * 0.5 - l.size.x * 0.5, vp.y * 0.22)
	await get_tree().process_frame
	l.position.x = vp.x * 0.5 - l.size.x * 0.5
	l.pivot_offset = l.size * 0.5
	l.scale = Vector2.ONE * 0.6
	var tw := l.create_tween()
	tw.tween_property(l, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.8)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


func _build_chest_panel() -> void:
	chest_panel = PanelContainer.new()
	chest_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	chest_panel.visible = false
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	var title := Label.new()
	title.text = "RƯƠNG BÁU VẬT!"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	chest_text = Label.new()
	chest_text.add_theme_font_size_override("font_size", 22)
	chest_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(chest_text)
	var btn := Button.new()
	btn.text = "Nhận!"
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(_close_chest)
	vbox.add_child(btn)
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
	var title := Label.new()
	title.text = "TẠM DỪNG"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.15, 0.17, 0.25))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	var resume := Button.new()
	resume.text = "Tiếp tục"
	resume.add_theme_font_size_override("font_size", 22)
	resume.pressed.connect(_toggle_pause)
	vbox.add_child(resume)
	var reset := Button.new()
	reset.text = "Chọn lại nhân vật"
	reset.add_theme_font_size_override("font_size", 22)
	reset.pressed.connect(_restart_game)
	vbox.add_child(reset)
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
	over_label.text = "GAME OVER\nSống sót: %02d:%02d — %d kills\nNhấn R để chơi lại" % [int(time) / 60, int(time) % 60, kills]
	over_label.visible = true
