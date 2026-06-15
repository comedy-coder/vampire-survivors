extends Area2D

# Đồng Vàng rơi ra từ quái / thùng gỗ — nhặt như gem, bị nam châm hút.
signal collected(value: int)

const CIRCLE := preload("res://assets/circle.svg")
const TEX_GLOW := preload("res://assets/vfx/glow.png")

var player: Node2D
var value := 1
var force_pull := false
var pull_speed := 0.0

var _bob_t := 0.0
var _glow_spr: Sprite2D
var _coin_spr: Sprite2D
var _base_scale := 0.2


func _ready() -> void:
	add_to_group("coins")
	_bob_t = randf() * TAU

	_glow_spr = Sprite2D.new()
	_glow_spr.texture = TEX_GLOW
	_glow_spr.modulate = Color(1.0, 0.8, 0.15, 0.55)
	_glow_spr.scale = Vector2.ONE * (58.0 / TEX_GLOW.get_size().x)
	add_child(_glow_spr)

	_coin_spr = Sprite2D.new()
	_coin_spr.texture = CIRCLE
	_coin_spr.modulate = Color(1.0, 0.82, 0.2)
	_coin_spr.scale = Vector2.ONE * _base_scale
	add_child(_coin_spr)


func _physics_process(delta: float) -> void:
	_bob_t += delta * 3.0
	_coin_spr.position.y = 2.5 * sin(_bob_t)
	# Lật ngang nhẹ như đồng xu đang quay + nảy nhẹ theo trục dọc
	_coin_spr.scale.x = _base_scale * (0.45 + 0.55 * absf(sin(_bob_t * 0.9)))
	_coin_spr.scale.y = _base_scale * (1.0 + 0.1 * sin(_bob_t * 1.6))
	_glow_spr.modulate.a = 0.5 + 0.18 * sin(_bob_t * 2.2)

	if player == null or not is_instance_valid(player):
		return
	var d := global_position.distance_to(player.global_position)
	if force_pull or d < player.magnet_range:
		pull_speed = minf(pull_speed + 1200.0 * delta, 700.0 if force_pull else 520.0)
		global_position = global_position.move_toward(player.global_position, pull_speed * delta)
	if d < 16.0:
		collected.emit(value)
		queue_free()
