extends Control

const RADIUS := 80.0
const KNOB := 34.0

var vec := Vector2.ZERO
var touch_id := -1
var base_pos := Vector2.ZERO
var knob_pos := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1 and event.position.x < get_viewport_rect().size.x * 0.55:
			touch_id = event.index
			base_pos = event.position
			knob_pos = base_pos
			queue_redraw()
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			vec = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == touch_id:
		var d: Vector2 = (event.position - base_pos).limit_length(RADIUS)
		knob_pos = base_pos + d
		vec = d / RADIUS
		queue_redraw()


func _draw() -> void:
	if touch_id == -1:
		return
	draw_circle(base_pos, RADIUS, Color(1.0, 1.0, 1.0, 0.10))
	draw_circle(base_pos, RADIUS, Color(1.0, 1.0, 1.0, 0.30), false, 3.0, true)
	draw_circle(knob_pos, KNOB, Color(1.0, 1.0, 1.0, 0.35))
