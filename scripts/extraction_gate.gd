extends Node2D

# Cổng thoát hiểm: hiện sau khi giết Mini-boss. Tồn tại 30s. Người chơi phải đứng
# trong vòng sáng 3 giây liên tục để rút lui an toàn (giữ 100% Vàng + Linh Hồn).
signal extracted
signal expired

const CIRCLE   := preload("res://assets/circle.svg")
const TEX_GLOW := preload("res://assets/vfx/glow.png")
const CHANNEL_NEED := 3.0

var player: Node2D
var radius := 95.0
var life := 30.0
var title := "EXTRACT"

var _channel := 0.0
var _t := 0.0
var _done := false
var _ring: Sprite2D
var _fill: Sprite2D
var _arc: Line2D
var _label: Label


func _ready() -> void:
	z_index = 6
	_ring = Sprite2D.new()
	_ring.texture = TEX_GLOW
	_ring.modulate = Color(0.4, 0.9, 1.0, 0.7)
	_ring.scale = Vector2.ONE * (radius * 2.6 / TEX_GLOW.get_size().x)
	add_child(_ring)

	_fill = Sprite2D.new()
	_fill.texture = CIRCLE
	_fill.modulate = Color(0.3, 0.8, 1.0, 0.22)
	_fill.scale = Vector2.ONE * (radius * 2.0 / CIRCLE.get_size().x)
	add_child(_fill)

	_arc = Line2D.new()
	_arc.width = 7.0
	_arc.default_color = Color(0.5, 1.0, 0.75)
	add_child(_arc)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.85))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 5)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.custom_minimum_size = Vector2(160, 0)
	_label.position = Vector2(-80, -radius - 50)
	add_child(_label)


func _process(delta: float) -> void:
	if _done:
		return
	_t += delta
	life -= delta
	_ring.modulate.a = 0.5 + 0.25 * sin(_t * 4.0)
	_fill.scale = Vector2.ONE * (radius * 2.0 / CIRCLE.get_size().x) * (1.0 + 0.05 * sin(_t * 3.0))

	if life <= 0.0:
		_done = true
		expired.emit()
		queue_free()
		return

	var inside: bool = player != null and is_instance_valid(player) and player.alive \
		and global_position.distance_to(player.global_position) <= radius
	if inside:
		_channel = minf(_channel + delta, CHANNEL_NEED)
	else:
		_channel = maxf(0.0, _channel - delta * 2.0)

	_update_arc()
	if _channel > 0.0:
		_label.text = "%s\n%d%%" % [title, int(_channel / CHANNEL_NEED * 100.0)]
	else:
		_label.text = "%s\n%ds" % [title, int(ceil(life))]

	if _channel >= CHANNEL_NEED:
		_done = true
		extracted.emit()
		queue_free()


func _update_arc() -> void:
	var pts := PackedVector2Array()
	var frac := _channel / CHANNEL_NEED
	var steps := 48
	var n := int(steps * frac)
	for i in range(n + 1):
		var a := -PI / 2.0 + TAU * (float(i) / steps)
		pts.append(Vector2.from_angle(a) * (radius + 12.0))
	_arc.points = pts
