extends CharacterBody2D

signal died

const PROJECTILE := preload("res://scripts/projectile.gd")
const CIRCLE := preload("res://assets/circle.svg")
const SND_SHOOT := preload("res://assets/audio/shoot.ogg")
const TEX_SPARK := preload("res://assets/vfx/spark.png")
const TEX_GLOW := preload("res://assets/vfx/glow.png")
const TEX_MUZZLE := preload("res://assets/vfx/muzzle.png")
const TEX_SWORD := preload("res://assets/vfx/sword.png")
const SND_BOOM := preload("res://assets/audio/explosion.ogg")
const SND_ZAP := preload("res://assets/audio/zap.ogg")

const WEAPONS := {
	"pistol": {"color": Color(1.0, 0.95, 0.6)},
	"smg": {"color": Color(0.5, 1.0, 1.0), "size": 0.13, "speed": 560.0, "spread": 0.12,
		"trail": Color(0.5, 1.0, 1.0, 0.45)},
	"shotgun": {"color": Color(1.0, 0.7, 0.25), "size": 0.13, "speed": 540.0, "life": 0.5,
		"extra_shots": 4, "scatter": true, "dmg_mul": 0.55, "kb": 220.0},
	"cannon": {"color": Color(0.85, 0.55, 1.0), "size": 0.3, "speed": 320.0, "aoe": 75.0,
		"kb": 260.0, "trail": Color(0.85, 0.55, 1.0, 0.35)},
	"laser": {"color": Color(0.4, 1.0, 0.5), "size": 0.15, "speed": 700.0, "stretch": 3.0,
		"pierce": 1, "trail": Color(0.4, 1.0, 0.5, 0.4)},
	"sniper": {"color": Color(1.0, 0.35, 0.3), "size": 0.17, "speed": 780.0, "kb": 320.0,
		"stretch": 2.0, "trail": Color(1.0, 0.35, 0.3, 0.45)},
}

var weapon := "pistol"
var speed := 220.0
var max_hp := 100.0
var hp := max_hp
var fire_rate := 1.5
var projectile_count := 1
var projectile_damage := 2.0
var pierce := 0
var magnet_range := 80.0
var regen := 0.0
var thorns := 0.0
var crit_chance := 0.0
var revive := false
var fire_timer := 0.0
var alive := true
var orbital_count := 0
var orbital_dps := 12.0
var grenade_level := 0
var grenade_timer := 0.0
var lightning_level := 0
var lightning_timer := 0.0
var poison_level := 0
var poison_ring := Sprite2D.new()
var shake_amt := 0.0
var walk_t := 0.0
var base_sprite_scale := Vector2.ONE
var orbital_evolved := false
var grenade_evolved := false
var lightning_evolved := false
var poison_evolved := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var cam: Camera2D = $Camera2D
@onready var orbit := Node2D.new()
@onready var shoot_sfx := AudioStreamPlayer.new()
@onready var boom_sfx := AudioStreamPlayer.new()
@onready var zap_sfx := AudioStreamPlayer.new()


func _ready() -> void:
	base_sprite_scale = sprite.scale
	add_child(orbit)
	shoot_sfx.stream = SND_SHOOT
	shoot_sfx.volume_db = -10.0
	add_child(shoot_sfx)
	boom_sfx.stream = SND_BOOM
	add_child(boom_sfx)
	zap_sfx.stream = SND_ZAP
	add_child(zap_sfx)
	poison_ring.texture = TEX_GLOW
	poison_ring.modulate = Color(0.3, 1.0, 0.3, 0.4)
	poison_ring.z_index = -5
	poison_ring.visible = false
	add_child(poison_ring)


func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide()

	if velocity.length_squared() > 0.0:
		walk_t += delta * 11.0
		sprite.scale = base_sprite_scale * Vector2(1.0 + 0.07 * sin(walk_t), 1.0 - 0.07 * sin(walk_t))
	else:
		sprite.scale = sprite.scale.lerp(base_sprite_scale, 12.0 * delta)

	var aim := _nearest_enemy()
	if aim != null:
		sprite.rotation = (aim.global_position - global_position).angle()
	elif velocity.length_squared() > 0.0:
		sprite.rotation = velocity.angle()

	fire_timer -= delta
	if fire_timer <= 0.0:
		fire_timer = 1.0 / fire_rate
		_fire()

	orbit.rotation += (4.6 if orbital_evolved else 2.8) * delta
	for blade in orbit.get_children():
		if blade.is_queued_for_deletion():
			continue
		for a in blade.get_overlapping_areas():
			if a.has_method("take_hit"):
				a.take_hit(orbital_dps * delta)

	if grenade_level > 0:
		grenade_timer -= delta
		if grenade_timer <= 0.0:
			grenade_timer = 3.0
			_fire_grenade()

	if lightning_level > 0:
		lightning_timer -= delta
		if lightning_timer <= 0.0:
			lightning_timer = 1.5 if lightning_evolved else 2.5
			_fire_lightning()

	if poison_level > 0:
		var pr := _poison_radius()
		var pdmg := 3.0 * poison_level * (2.0 if poison_evolved else 1.0) * delta
		for e in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(e.global_position) < pr:
				e.take_hit(pdmg)
				if poison_evolved:
					e.slow_timer = 0.2

	if regen > 0.0:
		heal(regen * delta)

	if thorns > 0.0:
		for e in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(e.global_position) < 42.0:
				e.take_hit(thorns * delta)

	if shake_amt > 0.0:
		cam.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_amt
		shake_amt = maxf(0.0, shake_amt - 35.0 * delta)
		if shake_amt == 0.0:
			cam.offset = Vector2.ZERO


func _fire() -> void:
	var target := _nearest_enemy()
	if target == null:
		return
	var base_dir := (target.global_position - global_position).normalized()
	shoot_sfx.pitch_scale = randf_range(0.9, 1.1)
	shoot_sfx.play()
	var cfg: Dictionary = WEAPONS[weapon]
	var wcolor: Color = cfg["color"]
	var m := Sprite2D.new()
	m.texture = TEX_MUZZLE
	m.rotation = base_dir.angle() + PI / 2.0
	m.scale = Vector2.ONE * (38.0 / TEX_MUZZLE.get_size().x)
	m.modulate = Color(wcolor.r, wcolor.g, wcolor.b, 0.9)
	m.z_index = 5
	get_parent().add_child(m)
	m.global_position = global_position + base_dir * 30.0
	var mtw := m.create_tween()
	mtw.tween_property(m, "modulate:a", 0.0, 0.09)
	mtw.tween_callback(m.queue_free)
	var shots: int = projectile_count + int(cfg.get("extra_shots", 0))
	for i in shots:
		var d := base_dir.rotated((i - (shots - 1) / 2.0) * float(cfg.get("spread", 0.18)))
		if cfg.get("scatter", false):
			d = base_dir.rotated(randf_range(-0.28, 0.28))
		var p := Area2D.new()
		p.set_script(PROJECTILE)
		p.dir = d
		p.damage = projectile_damage * float(cfg.get("dmg_mul", 1.0)) * (2.0 if randf() < crit_chance else 1.0)
		p.pierce = pierce + int(cfg.get("pierce", 0))
		p.speed = float(cfg.get("speed", 420.0)) * randf_range(0.95, 1.05)
		p.color = wcolor
		p.size = float(cfg.get("size", 0.18))
		p.kb = float(cfg.get("kb", 150.0))
		p.aoe = float(cfg.get("aoe", 0.0))
		p.stretch = float(cfg.get("stretch", 1.0))
		p.trail_color = cfg.get("trail", Color(0, 0, 0, 0))
		p.life = float(cfg.get("life", 2.0))
		get_parent().add_child(p)
		p.global_position = global_position


func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_d := INF
	for e in get_tree().get_nodes_in_group("enemies"):
		var d: float = global_position.distance_squared_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func _random_enemy_in(radius: float) -> Node2D:
	var list := []
	for e in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_to(e.global_position) < radius:
			list.append(e)
	if list.is_empty():
		return null
	return list.pick_random()


func _fire_grenade() -> void:
	var target := _random_enemy_in(450.0)
	if target == null:
		return
	var spr := Sprite2D.new()
	spr.texture = CIRCLE
	spr.scale = Vector2(0.16, 0.16)
	spr.modulate = Color(0.3, 0.45, 0.15)
	get_parent().add_child(spr)
	var start := global_position
	spr.global_position = start
	var dest: Vector2 = target.global_position
	var tw := spr.create_tween()
	tw.tween_method(
		func(t: float) -> void:
			spr.global_position = start.lerp(dest, t) + Vector2(0.0, -80.0 * sin(t * PI)),
		0.0, 1.0, 0.55)
	tw.tween_callback(_explode_grenade.bind(spr, dest))


func _explode_grenade(spr: Sprite2D, pos: Vector2) -> void:
	var radius := 90.0 + 10.0 * grenade_level
	var dmg := 8.0 + 4.0 * (grenade_level - 1)
	for e in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(e.global_position) < radius:
			e.take_hit(dmg, true, (e.global_position - pos).normalized() * 200.0)
	boom_sfx.pitch_scale = randf_range(0.9, 1.1)
	boom_sfx.play()
	shake_amt = maxf(shake_amt, 7.0)
	get_parent().spawn_explosion(pos, radius * 2.0)
	spr.queue_free()
	if grenade_evolved:
		for k in 3:
			var off := pos + Vector2.from_angle(randf() * TAU) * randf_range(40.0, 80.0)
			var tw := create_tween()
			tw.tween_interval(0.15 + 0.12 * k)
			tw.tween_callback(_mini_blast.bind(off, dmg * 0.5))


func _mini_blast(pos: Vector2, dmg: float) -> void:
	var radius := 60.0
	for e in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(e.global_position) < radius:
			e.take_hit(dmg, true, (e.global_position - pos).normalized() * 140.0)
	boom_sfx.pitch_scale = randf_range(1.1, 1.3)
	boom_sfx.play()
	shake_amt = maxf(shake_amt, 4.0)
	get_parent().spawn_explosion(pos, radius * 2.0, 0.4)


func _fire_lightning() -> void:
	var cur := _nearest_enemy()
	if cur == null or global_position.distance_to(cur.global_position) > 450.0:
		return
	var max_hits := 2 + lightning_level + (3 if lightning_evolved else 0)
	var dmg := 4.0 + 2.0 * lightning_level
	var hit: Array = []
	var pts: Array = [global_position]
	while cur != null and hit.size() < max_hits:
		hit.append(cur)
		pts.append(cur.global_position)
		cur.take_hit(dmg, true)
		var best: Node2D = null
		var best_d := 170.0 * 170.0
		for e in get_tree().get_nodes_in_group("enemies"):
			if e in hit:
				continue
			var d: float = pts[-1].distance_squared_to(e.global_position)
			if d < best_d:
				best_d = d
				best = e
		cur = best
	zap_sfx.pitch_scale = randf_range(0.95, 1.15)
	zap_sfx.play()
	var jagged := _jagged_points(pts)
	var glow := Line2D.new()
	glow.width = 11.0
	glow.default_color = Color(0.4, 0.7, 1.0, 0.35)
	glow.points = jagged
	get_parent().add_child(glow)
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = Color(0.85, 0.95, 1.0)
	line.points = jagged
	get_parent().add_child(line)
	for i in range(1, pts.size()):
		_spawn_flash(pts[i])
	var tw := line.create_tween()
	tw.set_parallel(true)
	tw.tween_property(line, "modulate:a", 0.0, 0.22)
	tw.tween_property(glow, "modulate:a", 0.0, 0.22)
	tw.chain().tween_callback(line.queue_free)
	tw.chain().tween_callback(glow.queue_free)


func _jagged_points(pts: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.append(pts[0])
	for i in range(1, pts.size()):
		var a: Vector2 = pts[i - 1]
		var b: Vector2 = pts[i]
		var perp := (b - a).normalized().orthogonal()
		var subdiv := 4
		for j in range(1, subdiv):
			var t := float(j) / subdiv
			out.append(a.lerp(b, t) + perp * randf_range(-12.0, 12.0))
		out.append(b)
	return out


func _spawn_flash(pos: Vector2) -> void:
	var f := Sprite2D.new()
	f.texture = TEX_SPARK
	var base := 35.0 / TEX_SPARK.get_size().x
	f.scale = Vector2.ONE * base
	f.modulate = Color(0.7, 0.9, 1.0, 0.95)
	f.rotation = randf() * TAU
	f.z_index = 15
	get_parent().add_child(f)
	f.global_position = pos
	var tw := f.create_tween()
	tw.set_parallel(true)
	tw.tween_property(f, "scale", Vector2.ONE * base * 2.6, 0.18)
	tw.tween_property(f, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(f.queue_free)


func _poison_radius() -> float:
	return (100.0 + 15.0 * poison_level) * (1.5 if poison_evolved else 1.0)


func update_poison_ring() -> void:
	poison_ring.visible = poison_level > 0
	var diameter := _poison_radius() * 2.0
	poison_ring.scale = Vector2.ONE * (diameter / TEX_GLOW.get_size().x)
	if poison_evolved:
		poison_ring.modulate = Color(0.2, 1.0, 0.25, 0.55)


func take_damage(amount: float) -> void:
	if not alive:
		return
	hp -= amount
	if hp <= 0.0:
		if revive:
			revive = false
			hp = max_hp * 0.5
			for e in get_tree().get_nodes_in_group("enemies"):
				var away: Vector2 = e.global_position - global_position
				if away.length() < 320.0:
					e.take_hit(15.0, true, away.normalized() * 500.0)
			get_parent().spawn_explosion(global_position, 400.0, 0.5)
			shake_amt = 12.0
			return
		hp = 0.0
		alive = false
		hide()
		died.emit()


func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp)


func add_orbital() -> void:
	orbital_count += 1
	_rebuild_orbitals()


func evolve_orbitals() -> void:
	orbital_evolved = true
	orbital_dps *= 2.2
	_rebuild_orbitals()


func _rebuild_orbitals() -> void:
	for c in orbit.get_children():
		c.queue_free()
	var blade_size := 52.0 if orbital_evolved else 36.0
	var blade_radius := 72.0 if orbital_evolved else 58.0
	var blade_color := Color(1.0, 0.85, 0.35) if orbital_evolved else Color(0.85, 0.9, 1.0)
	for i in orbital_count:
		var ang := TAU * i / orbital_count
		var b := Area2D.new()
		var cs := CollisionShape2D.new()
		var c := CircleShape2D.new()
		c.radius = 18.0 if orbital_evolved else 14.0
		cs.shape = c
		b.add_child(cs)
		var s := Sprite2D.new()
		s.texture = TEX_SWORD
		s.modulate = blade_color
		s.scale = Vector2.ONE * (blade_size / TEX_SWORD.get_size().x)
		# Icon kiếm gốc chĩa lên góc 45°, xoay thêm để mũi kiếm hướng ra ngoài
		s.rotation = ang + PI / 4.0
		b.add_child(s)
		b.position = Vector2.from_angle(ang) * blade_radius
		orbit.add_child(b)
