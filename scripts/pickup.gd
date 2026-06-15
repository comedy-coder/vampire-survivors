extends Area2D

signal taken(kind: String)

const TEX_GLOW := preload("res://assets/vfx/glow.png")
const CIRCLE   := preload("res://assets/circle.svg")

var player: Node2D
var kind := "heal"
var icon: Texture2D
var glow_col := Color.WHITE

var _bob_t := 0.0
var _glow_spr: Sprite2D
var _ring_spr: Sprite2D
var _spr: Sprite2D


func _ready() -> void:
	_bob_t = randf() * TAU

	# Outer glow lớn
	_glow_spr = Sprite2D.new()
	_glow_spr.texture = TEX_GLOW
	_glow_spr.modulate = Color(glow_col.r, glow_col.g, glow_col.b, 0.55)
	_glow_spr.scale = Vector2.ONE * (90.0 / TEX_GLOW.get_size().x)
	add_child(_glow_spr)

	# Inner ring nhỏ xoay ngược
	_ring_spr = Sprite2D.new()
	_ring_spr.texture = TEX_GLOW
	_ring_spr.modulate = Color(glow_col.r, glow_col.g, glow_col.b, 0.35)
	_ring_spr.scale = Vector2.ONE * (48.0 / TEX_GLOW.get_size().x)
	add_child(_ring_spr)

	# Icon
	_spr = Sprite2D.new()
	_spr.texture = icon
	_spr.scale = Vector2.ONE * (34.0 / icon.get_size().x)
	add_child(_spr)

	# Particles theo loại
	var p := CPUParticles2D.new()
	p.texture = CIRCLE
	p.emitting = true
	p.one_shot = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.direction = Vector2(0.0, -1.0)
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	match kind:
		"heal":
			p.amount = 8
			p.lifetime = 1.0
			p.emission_sphere_radius = 10.0
			p.initial_velocity_min = 10.0
			p.initial_velocity_max = 26.0
			p.scale_amount_min = 0.06
			p.scale_amount_max = 0.15
			p.color = Color(0.3, 1.0, 0.45, 0.85)
		"magnet":
			p.amount = 6
			p.lifetime = 0.8
			p.emission_sphere_radius = 12.0
			p.initial_velocity_min = 8.0
			p.initial_velocity_max = 22.0
			p.scale_amount_min = 0.05
			p.scale_amount_max = 0.12
			p.color = Color(0.3, 0.85, 1.0, 0.8)
		"bomb":
			p.amount = 9
			p.lifetime = 0.7
			p.emission_sphere_radius = 9.0
			p.initial_velocity_min = 15.0
			p.initial_velocity_max = 35.0
			p.scale_amount_min = 0.07
			p.scale_amount_max = 0.18
			p.color = Color(1.0, 0.55, 0.15, 0.9)
	add_child(p)


func _physics_process(delta: float) -> void:
	_bob_t += delta * 3.2

	# Icon bob + scale bounce
	_spr.position.y = -4.0 + 4.0 * sin(_bob_t)
	var bounce := 1.0 + 0.08 * sin(_bob_t * 2.0)
	_spr.scale = Vector2.ONE * (34.0 / icon.get_size().x) * bounce

	# Outer glow xoay chậm + pulse alpha
	_glow_spr.rotation += delta * 0.5
	_glow_spr.modulate.a = 0.55 + 0.18 * sin(_bob_t * 1.8)

	# Inner ring xoay ngược nhanh hơn
	_ring_spr.rotation -= delta * 1.1
	_ring_spr.modulate.a = 0.35 + 0.15 * sin(_bob_t * 2.5 + 1.0)

	if player == null or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) < 26.0:
		taken.emit(kind)
		queue_free()
