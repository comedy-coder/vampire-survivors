extends Node

# Cho phép điều khiển các màn tạm dừng (chọn nâng cấp khi LÊN CẤP, chọn NHÂN VẬT,
# mở RƯƠNG) bằng bàn phím: WASD / phím mũi tên để di chuyển, Space hoặc Enter để
# chọn — khỏi phải với tay dùng chuột giữa trận.
# Node này đặt PROCESS_MODE_ALWAYS nên vẫn nhận phím khi game đang tạm dừng.

signal nav(dx: int, dy: int)   # hướng di chuyển: trái/phải = dx ∓1, lên/xuống = dy ∓1
signal accept
signal restart                 # phím R — chơi lại / về menu (hoạt động cả khi game đã pause)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		nav.emit(-1, 0)
	elif event.is_action_pressed("move_right"):
		nav.emit(1, 0)
	elif event.is_action_pressed("move_up"):
		nav.emit(0, -1)
	elif event.is_action_pressed("move_down"):
		nav.emit(0, 1)
	elif event.is_action_pressed("ui_accept"):
		accept.emit()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		accept.emit()
	elif event.is_action_pressed("restart"):
		restart.emit()
