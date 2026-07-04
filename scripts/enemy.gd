extends Area2D

signal died(pos: Vector2, gems: int)
signal summon(pos: Vector2)
signal tornado(pos: Vector2)
signal quicksand(pos: Vector2)

const ENEMY_BULLET    := preload("res://scripts/enemy_projectile.gd")
const TEX_GLOW        := preload("res://assets/vfx/glow.png")
const TEX_FREEZE_START  := preload("res://assets/vfx/freeze_start.png")
const TEX_FREEZE_ACTIVE := preload("res://assets/vfx/freeze_active.png")
const TEX_FREEZE_END    := preload("res://assets/vfx/freeze_end.png")
const ELITE_BADGES := {
	"regen": preload("res://assets/icons/elite_regen.png"),
	"split": preload("res://assets/icons/elite_split.png"),
	"explode": preload("res://assets/icons/elite_explode.png"),
}

enum Kind { MELEE, RANGER, BOSS }
enum State { CHASE, TELEGRAPH, DASH }

var player: Node2D
var hp := 3.0
var speed := 60.0
var dps := 15.0
var tex: Texture2D = preload("res://assets/characters/zombie.png")
var sprite_scale := 0.75
var vis_scale := 0.0  # nếu > 0 thì hình vẽ dùng scale này, hitbox vẫn theo sprite_scale
var upright := false  # boss kiểu quái blob: không xoay theo hướng đi, chỉ lật trái/phải
var tint := Color.WHITE
var gems := 1

var elite_mod := ""  # "" / regen / split / explode / shield / vampire — quái tinh nhuệ
var unstoppable := false  # Tử Thần: miễn làm chậm / đóng băng khi di chuyển
var shield_hits := 0  # elite Khiên: số đòn mạnh còn chặn được (đòn tick DoT/aura xuyên khiên)
var shield_spr: Sprite2D
var hp_max := 0.0
var can_revive := false  # Vùng đất chết: quái hồi sinh 1 lần khi chết
var revived := false
var badge: Sprite2D

var kind := Kind.MELEE
var shoot_range := 320.0
var shoot_interval := 2.2
var bullet_damage := 8.0
var skills: Array = []  # "dash", "summon", "burst", "tornado", "quicksand", "spiral"
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
var poison_timer := 0.0
var freeze_timer := 0.0
var frost_dot := 0.0
var frost_dot_timer := 0.0
var burn_dot := 0.0    # đốt cháy (lõi Đạn Lửa) — tách khỏi frost_dot để cháy + băng cộng dồn
var burn_timer := 0.0
var walk_t := randf() * TAU
var strafe := 0.0
var poison_parts: CPUParticles2D
var freeze_overlay: Sprite2D
var freeze_gfx: AnimatedSprite2D
var freeze_was_active := false


func _ready() -> void:
	add_to_group("enemies")
	strafe = (1.0 if randf() < 0.5 else -1.0) * randf_range(0.5, 1.0)
	shoot_range *= randf_range(0.8, 1.25)
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 13.0 * (sprite_scale / 0.75)
	cs.shape = c
	add_child(cs)
	if vis_scale <= 0.0:
		vis_scale = sprite_scale
	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.scale = Vector2(vis_scale, vis_scale)
	sprite.modulate = tint
	add_child(sprite)
	hp_max = hp
	freeze_overlay = Sprite2D.new()
	freeze_overlay.texture = TEX_GLOW
	freeze_overlay.modulate = Color(0.7, 0.92, 1.0, 0.0)
	freeze_overlay.scale = Vector2.ONE * (80.0 * (sprite_scale / 0.75) / TEX_GLOW.get_size().x)
	freeze_overlay.z_index = 3
	add_child(freeze_overlay)
	freeze_gfx = _make_freeze_sprite()
	freeze_gfx.z_index = -2
	freeze_gfx.scale = Vector2.ONE * (sprite_scale / 0.75) * 1.8
	freeze_gfx.visible = false
	add_child(freeze_gfx)
	freeze_gfx.animation_finished.connect(_on_freeze_anim_finished)
	poison_parts = CPUParticles2D.new()
	poison_parts.texture = preload("res://assets/circle.svg")
	poison_parts.amount = 10
	poison_parts.lifetime = 0.9
	poison_parts.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	poison_parts.emission_sphere_radius = 10.0 * (sprite_scale / 0.75)
	poison_parts.gravity = Vector2(0.0, -30.0)
	poison_parts.initial_velocity_min = 5.0
	poison_parts.initial_velocity_max = 18.0
	poison_parts.scale_amount_min = 0.03
	poison_parts.scale_amount_max = 0.07
	var pg := Gradient.new()
	pg.set_color(0, Color(0.3, 1.0, 0.35, 0.0))
	pg.set_color(1, Color(0.3, 1.0, 0.35, 0.0))
	pg.add_point(0.2, Color(0.4, 1.0, 0.4, 0.7))
	poison_parts.color_ramp = pg
	poison_parts.z_index = 2
	poison_parts.emitting = false
	add_child(poison_parts)
	if elite_mod != "":
		var aura := Sprite2D.new()
		aura.texture = TEX_GLOW
		aura.modulate = _aura_color()
		aura.scale = Vector2.ONE * (95.0 * (sprite_scale / 0.75) / TEX_GLOW.get_size().x)
		aura.z_index = -1
		add_child(aura)
		# Các mod mới (shield/vampire) không có icon badge — nhận diện qua màu aura + hiệu ứng
		if ELITE_BADGES.has(elite_mod):
			var tex_badge: Texture2D = ELITE_BADGES[elite_mod]
			badge = Sprite2D.new()
			badge.texture = tex_badge
			badge.scale = Vector2.ONE * (22.0 / tex_badge.get_size().x)
			badge.z_index = 12
			add_child(badge)
		if elite_mod == "shield":
			# Vòng khiên xanh sáng — vỡ dần theo số đòn chặn được
			shield_spr = Sprite2D.new()
			shield_spr.texture = TEX_GLOW
			shield_spr.modulate = Color(0.65, 0.9, 1.0, 0.75)
			shield_spr.scale = Vector2.ONE * (70.0 * (sprite_scale / 0.75) / TEX_GLOW.get_size().x)
			shield_spr.z_index = 4
			add_child(shield_spr)


func _aura_color() -> Color:
	match elite_mod:
		"regen":
			return Color(0.3, 1.0, 0.4, 0.5)
		"split":
			return Color(0.4, 0.8, 1.0, 0.5)
		"shield":
			return Color(0.75, 0.9, 1.0, 0.55)
		"vampire":
			return Color(0.9, 0.15, 0.3, 0.55)
		_:
			return Color(1.0, 0.45, 0.2, 0.5)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	slow_timer = maxf(0.0, slow_timer - delta)
	poison_timer = maxf(0.0, poison_timer - delta)
	poison_parts.emitting = poison_timer > 0.0
	freeze_timer = maxf(0.0, freeze_timer - delta)
	freeze_overlay.modulate.a = minf(freeze_timer / 0.3, 1.0) * 0.75
	if freeze_timer > 0.0 and not freeze_was_active:
		freeze_was_active = true
		freeze_gfx.visible = true
		freeze_gfx.play("start")
	elif freeze_timer <= 0.0 and freeze_was_active:
		freeze_was_active = false
		if freeze_gfx.animation != "end":
			freeze_gfx.play("end")
	# Sát thương theo thời gian: băng và cháy là hai hiệu ứng riêng, cộng dồn được
	var dot := 0.0
	if frost_dot_timer > 0.0:
		frost_dot_timer -= delta
		dot += frost_dot
	if burn_timer > 0.0:
		burn_timer -= delta
		dot += burn_dot
	if dot > 0.0:
		hp -= dot * delta
		var gp := get_parent()
		if gp != null and gp.has_method("report_damage"):
			gp.report_damage("dot", dot * delta)
		if hp <= 0.0:
			if can_revive and not revived:
				_revive()
			else:
				died.emit.call_deferred(global_position, gems)
				queue_free()
				return
	if elite_mod == "regen":
		hp = minf(hp + hp_max * 0.03 * delta, hp_max)
	if kb_vel != Vector2.ZERO:
		global_position += kb_vel * delta
		kb_vel = kb_vel.move_toward(Vector2.ZERO, 900.0 * delta)
	if flash_timer > 0.0:
		flash_timer -= delta
		sprite.modulate = tint.lerp(Color(2.0, 2.0, 2.0), flash_timer / 0.07)
	elif freeze_timer > 0.0:
		sprite.modulate = tint * Color(0.65, 0.88, 1.0)
	elif poison_timer > 0.0:
		var pt := minf(poison_timer, 0.5) / 0.5
		sprite.modulate = tint * Color(0.55 + 0.45 * (1.0 - pt), 1.2, 0.55 + 0.45 * (1.0 - pt))
	elif burn_timer > 0.0:
		sprite.modulate = tint * Color(1.4, 0.75, 0.5)
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
	if upright:
		rotation = 0.0
		sprite.flip_h = to_player.x < 0.0
	if badge != null:
		# Giữ icon đứng thẳng và nổi trên đầu dù thân quái xoay theo hướng đi
		badge.global_rotation = 0.0
		badge.global_position = global_position \
			+ Vector2(0.0, -30.0 * (sprite_scale / 0.75) - 6.0 + 2.0 * sin(walk_t * 1.5))


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
	var spd := 0.0 if freeze_timer > 0.0 else speed * (0.6 if slow_timer > 0.0 else 1.0)
	if unstoppable:
		spd = speed  # Tử Thần không thể bị cản bước

	walk_t += delta * spd * 0.12
	sprite.rotation = 0.14 * sin(walk_t)
	sprite.scale = Vector2.ONE * vis_scale * (1.0 + 0.05 * sin(walk_t * 2.0))

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
		# Elite Hút Máu: cắn được người chơi thì tự hồi gấp đôi lượng cắn
		if elite_mod == "vampire":
			hp = minf(hp + dps * delta * 2.0, hp_max)

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
		"tornado":
			tornado.emit(global_position)
		"quicksand":
			quicksand.emit(player.global_position)
		"spiral":
			_fire_spiral()


func _fire_ring() -> void:
	var count := 10
	var offset := randf() * TAU
	for i in count:
		_spawn_bullet(Vector2.from_angle(offset + TAU * i / count), 200.0)


func _fire_spiral() -> void:
	# Bắn chuỗi đạn xoay tròn như xoắn ốc, người chơi phải chạy né liên tục
	var base := randf() * TAU
	var tw := create_tween()
	for i in 20:
		tw.tween_interval(0.08)
		tw.tween_callback(_spawn_bullet.bind(Vector2.from_angle(base + i * 0.55), 185.0))


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
	# Elite Khiên: chặn trọn các đòn đánh mạnh (đòn có hiện số); tick DoT/aura xuyên khiên
	if shield_hits > 0 and show_dmg:
		shield_hits -= 1
		flash_timer = 0.07
		if is_instance_valid(shield_spr):
			shield_spr.modulate.a = 0.25 + 0.25 * shield_hits
			if shield_hits <= 0:
				# Khiên vỡ: vòng sáng nổ tung ra
				var burst := shield_spr.create_tween()
				burst.set_parallel(true)
				burst.tween_property(shield_spr, "scale", shield_spr.scale * 2.5, 0.3)
				burst.tween_property(shield_spr, "modulate:a", 0.0, 0.3)
				burst.chain().tween_callback(shield_spr.queue_free)
		return
	hp -= damage
	if show_dmg:
		flash_timer = 0.07
	if kb != Vector2.ZERO:
		kb_vel = kb * (0.25 if kind == Kind.BOSS else 1.0)
	if show_dmg:
		_spawn_dmg_text(damage, col, crit)
	if hp <= 0.0:
		# Vùng đất chết: hồi sinh 1 lần thay vì chết hẳn
		if can_revive and not revived:
			_revive()
			return
		var overkill := hp <= -hp_max * 0.2
		# Overkill bằng đòn nặng (nổ/đẩy mạnh) → văng xác vỡ thành mảnh vụn
		if kind != Kind.BOSS and kb.length() >= 180.0 and hp <= -hp_max * 0.15:
			_spawn_shatter(kb)
		if is_instance_valid(player):
			var g := player.get_parent()
			if g != null:
				# Crit hạ gục → khựng khung hình rất ngắn cho cảm giác va đập
				if crit and g.has_method("request_hit_stop"):
					g.request_hit_stop(0.05)

		died.emit.call_deferred(global_position, gems)
		queue_free()


func _revive() -> void:
	revived = true
	hp = hp_max * 0.45
	flash_timer = 0.07
	# Lóe sáng xanh + phình to rồi co lại báo hiệu hồi sinh
	var ring := Sprite2D.new()
	ring.texture = TEX_GLOW
	ring.modulate = Color(0.4, 1.0, 0.5, 0.8)
	ring.scale = Vector2.ONE * (50.0 * (sprite_scale / 0.75) / TEX_GLOW.get_size().x)
	ring.z_index = 3
	add_child(ring)
	var tw := ring.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", ring.scale * 2.2, 0.45).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.45)
	tw.chain().tween_callback(ring.queue_free)


func _spawn_shatter(kb: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var base_dir := kb.normalized()
	var power := clampf(kb.length() / 400.0, 0.6, 2.2)
	for i in 6:
		var sh := Sprite2D.new()
		sh.texture = tex
		sh.modulate = tint
		sh.scale = Vector2(vis_scale, vis_scale) * randf_range(0.3, 0.5)
		sh.z_index = 9
		parent.add_child(sh)
		sh.global_position = global_position
		var ang := base_dir.rotated(randf_range(-1.0, 1.0))
		var dest := global_position + ang * randf_range(45.0, 120.0) * power
		var tw := sh.create_tween()
		tw.set_parallel(true)
		tw.tween_property(sh, "global_position", dest, randf_range(0.3, 0.5)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(sh, "rotation", randf_range(-TAU, TAU), 0.45)
		tw.tween_property(sh, "scale", sh.scale * 0.15, 0.45)
		tw.tween_property(sh, "modulate:a", 0.0, 0.45)
		tw.chain().tween_callback(sh.queue_free)


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


func _make_freeze_sprite() -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	sf.add_animation("start")
	sf.set_animation_loop("start", false)
	sf.set_animation_speed("start", 14.0)
	for i in 9:
		var a := AtlasTexture.new()
		a.atlas = TEX_FREEZE_START
		a.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("start", a)
	sf.add_animation("active")
	sf.set_animation_loop("active", true)
	sf.set_animation_speed("active", 10.0)
	for i in 8:
		var a := AtlasTexture.new()
		a.atlas = TEX_FREEZE_ACTIVE
		a.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("active", a)
	sf.add_animation("end")
	sf.set_animation_loop("end", false)
	sf.set_animation_speed("end", 14.0)
	for i in 18:
		var a := AtlasTexture.new()
		a.atlas = TEX_FREEZE_END
		a.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("end", a)
	var s := AnimatedSprite2D.new()
	s.sprite_frames = sf
	return s


func _on_freeze_anim_finished() -> void:
	match freeze_gfx.animation:
		"start": freeze_gfx.play("active")
		"end":   freeze_gfx.visible = false
