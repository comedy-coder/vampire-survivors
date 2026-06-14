extends Node2D

# Linh thú bay: lượn quanh người chơi và tự bắn quái gần nhất.
# Sinh ra bởi cổ vật "Linh thú bay" (_art_familiar trong game.gd).

const PROJECTILE := preload("res://scripts/projectile.gd")
const CIRCLE := preload("res://assets/circle.svg")
const TEX_GLOW := preload("res://assets/vfx/glow.png")

const COL := Color(0.4, 1.0, 0.85)

var player: Node2D
var fire_interval := 0.7
var shoot_range := 380.0
var orbit_radius := 74.0

var fire_timer := randf() * 0.5
var orbit_angle := randf() * TAU
var bob_t := randf() * TAU
var core: Sprite2D
var sparks: Node2D


func _ready() -> void:
	z_index = 4
	var glow := Sprite2D.new()
	glow.texture = TEX_GLOW
	glow.modulate = Color(COL.r, COL.g, COL.b, 0.5)
	glow.scale = Vector2.ONE * (60.0 / TEX_GLOW.get_size().x)
	add_child(glow)
	core = Sprite2D.new()
	core.texture = CIRCLE
	core.modulate = Color(0.8, 1.0, 0.95)
	core.scale = Vector2(0.2, 0.2)
	add_child(core)
	# Hai đốm sáng nhỏ xoay quanh lõi cho "có hồn"
	sparks = Node2D.new()
	add_child(sparks)
	for i in 2:
		var sp := Sprite2D.new()
		sp.texture = CIRCLE
		sp.modulate = Color(COL.r, COL.g, COL.b, 0.9)
		sp.scale = Vector2(0.07, 0.07)
		sp.position = Vector2.from_angle(PI * i) * 16.0
		sparks.add_child(sp)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return
	orbit_angle += delta * 1.3
	bob_t += delta * 3.2
	sparks.rotation += delta * 5.0
	core.scale = Vector2.ONE * 0.2 * (1.0 + 0.14 * sin(bob_t * 1.5))
	# Lượn quanh người chơi, hơi nhấp nhô lên xuống cho mượt
	var target := player.global_position \
		+ Vector2.from_angle(orbit_angle) * orbit_radius \
		+ Vector2(0.0, -12.0 + 5.0 * sin(bob_t))
	global_position = global_position.lerp(target, 7.0 * delta)

	fire_timer -= delta
	if fire_timer <= 0.0:
		var tgt := _nearest_enemy()
		if tgt != null:
			fire_timer = fire_interval
			_shoot(tgt)


func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_d := shoot_range * shoot_range
	for e in get_tree().get_nodes_in_group("enemies"):
		var d: float = global_position.distance_squared_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func _shoot(target: Node2D) -> void:
	# Sát thương bám theo chỉ số người chơi nên linh thú mạnh dần theo nâng cấp
	var is_crit: bool = randf() < player.crit_chance
	var dmg: float = (3.0 + player.projectile_damage * 0.5) * (2.0 if is_crit else 1.0)
	var p := Area2D.new()
	p.set_script(PROJECTILE)
	p.dir = (target.global_position - global_position).normalized()
	p.crit = is_crit
	p.damage = dmg
	p.speed = 500.0
	p.color = COL
	p.size = 0.13
	p.kb = 90.0
	p.trail_color = Color(COL.r, COL.g, COL.b, 0.4)
	p.life = 1.4
	get_parent().add_child(p)
	p.global_position = global_position
