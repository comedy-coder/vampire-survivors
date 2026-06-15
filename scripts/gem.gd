extends Area2D

signal collected(value: int)

const CIRCLE := preload("res://assets/circle.svg")
const TEX_GLOW := preload("res://assets/vfx/glow.png")

var player: Node2D
var value := 1
var force_pull := false
var pull_speed := 0.0

var _bob_t := 0.0
var _glow_spr: Sprite2D
var _gem_spr: Sprite2D
var _base_scale := 0.22


func _ready() -> void:
	add_to_group("gems")
	_bob_t = randf() * TAU

	var is_elite := value >= 5
	_base_scale = 0.34 if is_elite else 0.22
	var gem_col  := Color(1.0, 0.85, 0.25)     if is_elite else Color(0.3, 0.9, 1.0)
	var glow_col := Color(1.0, 0.72, 0.05, 0.7) if is_elite else Color(0.15, 0.75, 1.0, 0.55)
	var glow_px  := 110.0 if is_elite else 72.0

	# Glow — thêm trước gem_spr để render phía sau (cùng z, draw order sớm hơn)
	_glow_spr = Sprite2D.new()
	_glow_spr.texture = TEX_GLOW
	_glow_spr.modulate = glow_col
	_glow_spr.scale = Vector2.ONE * (glow_px / TEX_GLOW.get_size().x)
	add_child(_glow_spr)

	# Gem circle
	_gem_spr = Sprite2D.new()
	_gem_spr.texture = CIRCLE
	_gem_spr.modulate = gem_col
	_gem_spr.scale = Vector2.ONE * _base_scale
	add_child(_gem_spr)

	# Sparkle particles
	var p := CPUParticles2D.new()
	p.texture = CIRCLE
	p.emitting = true
	p.amount = 7 if is_elite else 4
	p.lifetime = 0.9 if is_elite else 1.1
	p.one_shot = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 8.0 if is_elite else 5.0
	p.direction = Vector2(0.0, -1.0)
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 14.0 if is_elite else 7.0
	p.initial_velocity_max = 32.0 if is_elite else 18.0
	p.scale_amount_min = 0.12 if is_elite else 0.07
	p.scale_amount_max = 0.26 if is_elite else 0.14
	p.color = Color(1.0, 0.9, 0.3, 0.9) if is_elite else Color(0.4, 0.95, 1.0, 0.8)
	add_child(p)


func _physics_process(delta: float) -> void:
	_bob_t += delta * 2.8

	_gem_spr.position.y = 3.0 * sin(_bob_t)

	var pulse := 1.0 + 0.1 * sin(_bob_t * 1.6)
	_gem_spr.scale = Vector2.ONE * _base_scale * pulse

	_glow_spr.rotation += delta * 0.55
	var base_a := 0.70 if value >= 5 else 0.55
	_glow_spr.modulate.a = base_a + 0.15 * sin(_bob_t * 2.2)

	if player == null or not is_instance_valid(player):
		return
	var d := global_position.distance_to(player.global_position)
	if force_pull or d < player.magnet_range:
		pull_speed = minf(pull_speed + 1200.0 * delta, 700.0 if force_pull else 500.0)
		global_position = global_position.move_toward(player.global_position, pull_speed * delta)
	if d < 16.0:
		collected.emit(value)
		queue_free()
