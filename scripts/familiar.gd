extends Node2D

const PROJECTILE     := preload("res://scripts/projectile.gd")
const CIRCLE         := preload("res://assets/circle.svg")
const TEX_GLOW       := preload("res://assets/vfx/glow.png")
const SFX_NOVA       := preload("res://assets/audio/nova.ogg")
const TEX_NOVA_ORB   := preload("res://assets/vfx/nova_orb.png")
const TEX_NOVA_BURST := preload("res://assets/vfx/nova_burst.png")

const COL            := Color(0.4, 1.0, 0.85)
const CHARGE_TIME    := 8.0   # giây nạp đầy
const NOVA_RADIUS    := 100.0
const NOVA_DAMAGE    := 38.0

var player: Node2D
var fire_interval  := 0.7
var shoot_range    := 380.0
var orbit_radius   := 74.0

var fire_timer  := randf() * 0.5
var orbit_angle := randf() * TAU
var bob_t       := randf() * TAU
var charge_t    := 0.0        # 0 → CHARGE_TIME

var core: Sprite2D
var glow_spr: Sprite2D
var sparks: Node2D
var charge_ring: Sprite2D     # vòng tròn nạp điện
var sfx: AudioStreamPlayer2D


func _ready() -> void:
	z_index = 4

	glow_spr = Sprite2D.new()
	glow_spr.texture = TEX_GLOW
	glow_spr.modulate = Color(COL.r, COL.g, COL.b, 0.5)
	glow_spr.scale = Vector2.ONE * (60.0 / TEX_GLOW.get_size().x)
	add_child(glow_spr)

	core = Sprite2D.new()
	core.texture = CIRCLE
	core.modulate = Color(0.8, 1.0, 0.95)
	core.scale = Vector2(0.2, 0.2)
	add_child(core)

	sparks = Node2D.new()
	add_child(sparks)
	for i in 2:
		var sp := Sprite2D.new()
		sp.texture = CIRCLE
		sp.modulate = Color(COL.r, COL.g, COL.b, 0.9)
		sp.scale = Vector2(0.07, 0.07)
		sp.position = Vector2.from_angle(PI * i) * 16.0
		sparks.add_child(sp)

	# Vòng nạp điện — mở rộng dần theo charge
	charge_ring = Sprite2D.new()
	charge_ring.texture = TEX_GLOW
	charge_ring.modulate = Color(COL.r, COL.g, COL.b, 0.0)
	charge_ring.scale = Vector2.ONE * 0.1
	add_child(charge_ring)

	sfx = AudioStreamPlayer2D.new()
	sfx.stream = SFX_NOVA
	sfx.pitch_scale = 0.38
	sfx.volume_db = 2.0
	add_child(sfx)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		queue_free()
		return

	orbit_angle += delta * 1.3
	bob_t       += delta * 3.2
	sparks.rotation += delta * 5.0

	# Tỉ lệ nạp 0→1
	var charge_ratio := charge_t / CHARGE_TIME

	# Pulse core theo charge
	var extra_pulse := 0.08 + 0.18 * charge_ratio
	core.scale = Vector2.ONE * 0.2 * (1.0 + extra_pulse * sin(bob_t * 1.5))

	# Glow sáng hơn khi gần đầy
	glow_spr.modulate.a = 0.5 + 0.45 * charge_ratio

	# Vòng nạp điện mở rộng
	var ring_px := 30.0 + 32.0 * charge_ratio
	charge_ring.scale = Vector2.ONE * (ring_px / TEX_GLOW.get_size().x)
	charge_ring.modulate.a = 0.15 + 0.5 * charge_ratio
	charge_ring.rotation += delta * (0.8 + charge_ratio * 1.4)

	var target := player.global_position \
		+ Vector2.from_angle(orbit_angle) * orbit_radius \
		+ Vector2(0.0, -12.0 + 5.0 * sin(bob_t))
	global_position = global_position.lerp(target, 7.0 * delta)

	# Nạp điện
	charge_t += delta
	if charge_t >= CHARGE_TIME:
		charge_t = 0.0
		_fire_nova()

	# Bắn thường
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
	var is_crit: bool = randf() < player.crit_chance
	var dmg: float = (3.0 + player.projectile_damage * 0.5) * (2.0 if is_crit else 1.0)
	var p := Area2D.new()
	p.set_script(PROJECTILE)
	p.src = "familiar"
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


func _fire_nova() -> void:

	var tgt := _nearest_enemy()
	var dir := (tgt.global_position - global_position).normalized() \
		if tgt != null else Vector2.from_angle(orbit_angle)

	var ball_life := 1.0
	var p := Area2D.new()
	p.set_script(PROJECTILE)
	p.src = "familiar"
	p.dir = dir
	p.damage = NOVA_DAMAGE
	p.speed = 380.0
	p.color = COL
	p.size = 0.01  # circle gốc ẩn đi
	p.aoe = NOVA_RADIUS
	p.kb = 380.0
	p.life = ball_life
	p.pierce = 999
	get_parent().add_child(p)
	p.global_position = global_position

	# Ẩn circle mặc định
	for child in p.get_children():
		if child is Sprite2D:
			child.visible = false
			break

	# AnimatedSprite2D orb từ nova_orb.png (đã recolor sang màu linh thú)
	var orb := _make_anim_sprite(TEX_NOVA_ORB, 96, 96, 12, 14, true)
	orb.play("default")
	p.add_child(orb)
	var tw := orb.create_tween()
	tw.tween_property(orb, "scale", Vector2.ONE * 2.8, ball_life - 0.1)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Luôn nổ khi hết life dù không trúng quái
	var t := get_tree().create_timer(ball_life)
	t.timeout.connect(func() -> void:
		if not is_instance_valid(p):
			return  # đã nổ do trúng quái rồi
		var boom_pos := p.global_position
		p.queue_free()
		sfx.play()
		var g := get_parent()
		for e in get_tree().get_nodes_in_group("enemies"):
			if boom_pos.distance_to(e.global_position) <= NOVA_RADIUS:
				var is_crit: bool = randf() < player.crit_chance
				var dmg_amt := NOVA_DAMAGE * (2.0 if is_crit else 1.0)
				# take_hit(dmg, show_dmg, kb, col, crit) — luôn hiện số, cờ crit đúng vị trí
				e.take_hit(dmg_amt, true,
					(e.global_position - boom_pos).normalized() * 380.0,
					COL, is_crit)
				if g != null and g.has_method("report_damage"):
					g.report_damage("familiar", dmg_amt)
		_spawn_nova_burst(boom_pos)
	)


func _make_anim_sprite(tex: Texture2D, fw: int, fh: int, frames: int, fps: int, loop: bool = false) -> AnimatedSprite2D:
	var sf := SpriteFrames.new()
	sf.clear("default")
	sf.set_animation_loop("default", loop)
	sf.set_animation_speed("default", fps)
	for i in frames:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fw, 0, fw, fh)
		sf.add_frame("default", at)
	var anim := AnimatedSprite2D.new()
	anim.sprite_frames = sf
	return anim


func _spawn_nova_burst(pos: Vector2) -> void:
	var node := Node2D.new()
	node.z_index = 6
	get_parent().add_child(node)
	node.global_position = pos

	# AnimatedSprite2D burst từ nova_burst.png (đã recolor)
	var burst := _make_anim_sprite(TEX_NOVA_BURST, 128, 128, 10, 20)
	burst.scale = Vector2.ONE * 3.0
	node.add_child(burst)
	burst.animation_finished.connect(node.queue_free)
	burst.play("default")

	# Ring glow mở rộng kèm theo
	var ring := Sprite2D.new()
	ring.texture = TEX_GLOW
	ring.modulate = Color(COL.r, COL.g, COL.b, 0.6)
	ring.scale = Vector2.ONE * 0.2
	node.add_child(ring)
	var tw := ring.create_tween()
	tw.set_parallel(true)
	var target_s: float = (NOVA_RADIUS * 2.0) / TEX_GLOW.get_size().x
	tw.tween_property(ring, "scale", Vector2.ONE * target_s, 0.5)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
