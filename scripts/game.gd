extends Node2D

const ENEMY := preload("res://scripts/enemy.gd")
const GEM := preload("res://scripts/gem.gd")

const TEX_ZOMBIE := preload("res://assets/characters/zombie.png")
const TEX_HITMAN := preload("res://assets/characters/hitman.png")
const TEX_ROBOT := preload("res://assets/characters/robot.png")

const BOSS_INTERVAL := 45.0

const UPGRADES := [
	{"label": "+0.6 Sát thương đạn", "fn": "_up_damage"},
	{"label": "+0.5 Tốc độ bắn", "fn": "_up_fire_rate"},
	{"label": "+1 Đạn mỗi phát", "fn": "_up_projectile"},
	{"label": "Đạn xuyên +1 mục tiêu", "fn": "_up_pierce"},
	{"label": "+25 Tốc độ chạy", "fn": "_up_speed"},
	{"label": "+25 Máu tối đa (hồi đầy)", "fn": "_up_max_hp"},
	{"label": "+1 Kiếm xoay quanh người", "fn": "_up_orbital"},
]

var time := 0.0
var kills := 0
var xp := 0
var level := 1
var xp_needed := 5
var spawn_timer := 0.0
var boss_timer := BOSS_INTERVAL
var game_over := false
var choosing := false
var pending: Array = []

@onready var player: CharacterBody2D = $Player
@onready var hp_label: Label = $UI/HpLabel
@onready var time_label: Label = $UI/TimeLabel
@onready var level_label: Label = $UI/LevelLabel
@onready var kills_label: Label = $UI/KillsLabel
@onready var over_label: Label = $UI/GameOverLabel
@onready var level_panel: PanelContainer = $UI/LevelUpPanel


func _ready() -> void:
	randomize()
	player.died.connect(_on_player_died)
	for i in 3:
		level_panel.get_node("VBox/Btn%d" % (i + 1)).pressed.connect(_choose.bind(i))


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	time += delta
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = maxf(0.25, 1.2 - time * 0.012)
		_spawn_enemy()

	boss_timer -= delta
	if boss_timer <= 0.0:
		boss_timer = BOSS_INTERVAL
		_spawn_boss()

	hp_label.text = "HP: %d / %d" % [int(player.hp), int(player.max_hp)]
	time_label.text = "%02d:%02d" % [int(time) / 60, int(time) % 60]
	level_label.text = "Level %d  (XP %d/%d)" % [level, xp, xp_needed]
	kills_label.text = "Kills: %d" % kills


func _make_enemy() -> Area2D:
	var e := Area2D.new()
	e.set_script(ENEMY)
	e.player = player
	e.died.connect(_on_enemy_died)
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
	elif time > 30.0 and r < 0.4:
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
	var e := _make_enemy()
	e.tex = TEX_ZOMBIE
	e.sprite_scale = 1.5
	e.tint = Color(1.0, 0.5, 0.5)
	e.hp = 50.0 + time * 1.5
	e.speed = 70.0
	e.dps = 30.0
	e.gems = 8
	add_child(e)
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 600.0


func _on_enemy_died(pos: Vector2, gem_count: int) -> void:
	kills += 1
	for i in gem_count:
		var g := Area2D.new()
		g.set_script(GEM)
		g.player = player
		g.collected.connect(_on_gem_collected)
		add_child(g)
		g.global_position = pos + Vector2.from_angle(randf() * TAU) * (randf() * 20.0)


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


func _on_player_died() -> void:
	game_over = true
	over_label.text = "GAME OVER\nSống sót: %02d:%02d — %d kills\nNhấn R để chơi lại" % [int(time) / 60, int(time) % 60, kills]
	over_label.visible = true
