extends Area2D

signal broke(pos: Vector2)

const TEX := preload("res://assets/decor/rock_1.png")
const TEX_GLOW := preload("res://assets/vfx/glow.png")
const TINT := Color(0.85, 0.75, 1.1)

var player: Node2D
var hp := 10.0
var sprite: Sprite2D


func _ready() -> void:
	add_to_group("crates")
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 20.0
	cs.shape = c
	add_child(cs)
	var glow := Sprite2D.new()
	glow.texture = TEX_GLOW
	glow.modulate = Color(0.75, 0.55, 1.0, 0.45)
	glow.scale = Vector2.ONE * (80.0 / TEX_GLOW.get_size().x)
	add_child(glow)
	sprite = Sprite2D.new()
	sprite.texture = TEX
	sprite.modulate = TINT
	add_child(sprite)
	# Người chơi chạm vào là vỡ ngay, không cần bắn
	body_entered.connect(func(body: Node2D) -> void:
		if body == player:
			take_hit(hp))


func take_hit(damage: float, _show := false, _kb := Vector2.ZERO, _col := Color.WHITE, _crit := false) -> void:
	if hp <= 0.0:
		return
	hp -= damage
	sprite.modulate = Color(2.0, 2.0, 2.0)
	var tw := sprite.create_tween()
	tw.tween_property(sprite, "modulate", TINT, 0.15)
	if hp <= 0.0:
		broke.emit(global_position)
		queue_free()
