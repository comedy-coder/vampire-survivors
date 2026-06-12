extends Area2D

signal died(pos: Vector2, gems: int)
signal summon(pos: Vector2)

const ENEMY_BULLET := preload("res://scripts/enemy_projectile.gd")

enum Kind { MELEE, RANGER, BOSS }
enum State { CHASE, TELEGRAPH, DASH }

var player: Node2D
var hp := 3.0
var speed := 60.0
var dps := 15.0
var tex: Texture2D = preload("res://assets/characters/zombie.png")
var sprite_scale := 0.75
var tint := Color.WHITE
var gems := 1

var kind := Kind.MELEE
var shoot_range := 320.0
var shoot_interval := 2.2
var bullet_damage := 8.0
var skills: Array = []  # "dash", "summon", "burst"
var skill_interval := 6.0

var state := State.CHASE
var shoot_timer := 1.2
var skill_timer := 3.0
var state_timer := 0.0
var dash_dir := Vector2.ZERO
var sprite: Sprite2D
var kb_vel := Vector2.ZERO
var flash_timer := 0.0
var slow_timer := 0.0
var walk_t := randf() * TAU
var strafe := 0.0


func _ready() -> void:
	add_to_group("enemies")
	strafe = (1.0 if randf() < 0.5 else -1.0) * randf_range(0.5, 1.0)
	shoot_range *= randf_range(0.8, 1.25)
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 13.0 * (sprite_scale / 0.75)
	cs.shape = c
	add_child(cs)
	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.modulate = tint
	add_child(sprite)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	slow_timer = maxf(0.0, slow_timer - delta)
	if kb_vel != Vector2.ZERO:
		global_position += kb_vel * delta
		kb_vel = kb_vel.move_toward(Vector2.ZERO, 900.0 * delta)
	if flash_timer > 0.0:
		flash_timer -= delta
		sprite.modulate = tint.lerp(Color(2.0, 2.0, 2.0), flash_timer / 0.07)
	elif slow_timer > 0.0:
		sprite.modulate = tint * Color(0.55, 0.8, 1.45)
	else:
		sprite.modulate = tint
	var to_player := player.global_position - global_position
	match state:
		State.CHASE:
			_chase(delta, to_player)
		State.TELEGRAPH:
			_telegraph(delta)
		State.DASH:
			_dash(delta, to_player)
	if state != State.DASH:
		_separate(delta)


func _separate(delta: float) -> void:
	var radius := 27.0 * (sprite_scale / 0.75)
	if kind == Kind.RANGER:
		radius = 55.0
	for a in get_overlapping_areas():
		if not a.is_in_group("enemies"):
			continue
		var away := global_position - a.global_position
		var d := away.length()
		if d < 0.5:
			away = Vector2.from_angle(randf() * TAU)
			d = 0.5
		if d < radius:
			global_position += away / d * (radius - d) * 7.0 * delta


func _chase(delta: float, to_player: Vector2) -> void:
	rotation = to_player.angle()
	var dist := to_player.length()
	var spd := speed * (0.6 if slow_timer > 0.0 else 1.0)

	walk_t += delta * spd * 0.12
	sprite.rotation = 0.14 * sin(walk_t)
	sprite.scale = Vector2.ONE * sprite_scale * (1.0 + 0.05 * sin(walk_t * 2.0))

	if kind == Kind.RANGER:
		# Giữ khoảng cách: xa thì tiến lại, gần quá thì lùi ra
		var fwd := to_player.normalized()
		if dist > shoot_range:
			global_position += fwd * spd * delta
		elif dist < shoot_range * 0.5:
			global_position -= fwd * spd * 0.6 * delta
		else:
			# Đi vòng quanh người chơi để không dồn cục một chỗ
			global_position += fwd.orthogonal() * spd * 0.55 * strafe * delta
		shoot_timer -= delta
		if shoot_timer <= 0.0 and dist <= shoot_range + 40.0:
			shoot_timer = shoot_interval
			_spawn_bullet(to_player.normalized())
	else:
		global_position += to_player.normalized() * spd * delta

	if dist < 24.0 * (sprite_scale / 0.75):
		player.take_damage(dps * delta)

	if kind == Kind.BOSS and not skills.is_empty():
		skill_timer -= delta
		if skill_timer <= 0.0:
			skill_timer = skill_interval
			_use_skill()


func _telegraph(delta: float) -> void:
	state_timer -= delta
	# Nhấp nháy đỏ báo hiệu sắp lao tới
	sprite.modulate = tint.lerp(Color(1.0, 0.15, 0.15), 0.5 + 0.5 * sin(state_timer * 40.0))
	if state_timer <= 0.0:
		sprite.modulate = tint
		state = State.DASH
		state_timer = 0.45
		dash_dir = (player.global_position - global_position).normalized()
		rotation = dash_dir.angle()


func _dash(delta: float, to_player: Vector2) -> void:
	state_timer -= delta
	global_position += dash_dir * speed * 5.0 * delta
	if to_player.length() < 30.0 * (sprite_scale / 0.75):
		player.take_damage(dps * 3.0 * delta)
	if state_timer <= 0.0:
		state = State.CHASE


func _use_skill() -> void:
	match skills.pick_random():
		"dash":
			state = State.TELEGRAPH
			state_timer = 0.6
		"summon":
			summon.emit(global_position)
		"burst":
			_fire_ring()


func _fire_ring() -> void:
	var count := 10
	var offset := randf() * TAU
	for i in count:
		_spawn_bullet(Vector2.from_angle(offset + TAU * i / count), 200.0)


func _spawn_bullet(d: Vector2, spd := 240.0) -> void:
	var b := Area2D.new()
	b.set_script(ENEMY_BULLET)
	b.player = player
	b.dir = d
	b.speed = spd
	b.damage = bullet_damage
	get_parent().add_child(b)
	b.global_position = global_position + d * 20.0


func take_hit(damage: float, show_dmg := false, kb := Vector2.ZERO, col := Color(1.0, 0.9, 0.3), crit := false) -> void:
	if hp <= 0.0:
		return
	hp -= damage
	if show_dmg:
		flash_timer = 0.07
	if kb != Vector2.ZERO:
		kb_vel = kb * (0.25 if kind == Kind.BOSS else 1.0)
	if show_dmg:
		_spawn_dmg_text(damage, col, crit)
	if hp <= 0.0:
		died.emit(global_position, gems)
		queue_free()


func _spawn_dmg_text(damage: float, col: Color, crit: bool) -> void:
	var l := Label.new()
	l.text = str(maxi(1, int(roundf(damage)))) + ("!" if crit else "")
	l.z_index = 20
	l.add_theme_font_size_override("font_size", 26 if crit else 16)
	l.add_theme_color_override("font_color", Color(1.0, 0.35, 0.2) if crit else col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6 if crit else 4)
	get_parent().add_child(l)
	l.global_position = global_position + Vector2(randf_range(-14.0, 6.0), -34.0)
	var rise := -55.0 if crit else -35.0
	var tw := l.create_tween()
	tw.set_parallel(true)
	if crit:
		l.scale = Vector2.ONE * 1.6
		tw.tween_property(l, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK)
	tw.tween_property(l, "global_position", l.global_position + Vector2(0, rise), 0.55)
	tw.tween_property(l, "modulate:a", 0.0, 0.55).set_delay(0.15)
	tw.chain().tween_callback(l.queue_free)
