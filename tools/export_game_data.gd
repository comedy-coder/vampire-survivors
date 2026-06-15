extends SceneTree

# ============================================================================
#  Tự trích xuất thông số game từ scripts/*.gd ra JSON.
#
#  Chạy:  godot --headless --script tools/export_game_data.gd
#         (hoặc dùng tools/export-data.sh)
#
#  - Các BẢNG dữ liệu (const dict/array): lấy nguyên giá trị đã đánh giá
#    (nhân vật, vũ khí, nâng cấp, cổ vật, meta, vùng, boss...).
#  - "thong_so_so": quét mọi biến/hằng vô hướng SỐ khai báo ở mức class
#    (player base stats, enemy stats, timer, hằng linh thú...).
#  - LƯU Ý: công thức nằm trong thân hàm (vd "120 + 20*level") KHÔNG trích được.
# ============================================================================

const OUT_PATH := "res://game_data.json"

# Các script sẽ quét biến/hằng vô hướng số
const SCALAR_SOURCES := {
	"player": "res://scripts/player.gd",
	"enemy": "res://scripts/enemy.gd",
	"familiar": "res://scripts/familiar.gd",
	"projectile": "res://scripts/projectile.gd",
	"boomerang": "res://scripts/boomerang.gd",
	"game": "res://scripts/game.gd",
}


func _initialize() -> void:
	var out := {}
	out["_meta"] = {
		"nguon": "Tự trích từ scripts/*.gd bằng tools/export_game_data.gd",
		"ghi_chu": "Bảng dữ liệu (const) lấy nguyên giá trị; 'thong_so_so' là biến/hằng vô hướng số ở mức class. Công thức trong thân hàm KHÔNG được trích.",
	}

	# ---- 1) Bảng dữ liệu const trong game.gd ----
	var game: GDScript = load("res://scripts/game.gd")
	var gc := game.get_script_constant_map()
	out["nhan_vat"] = _san(gc.get("CHARACTERS"))
	out["nang_cap_chi_so_levelup"] = _san(gc.get("STAT_UPGRADES"))
	out["co_vat_artifact"] = _san(gc.get("ARTIFACTS"))
	out["nang_cap_vinh_vien_shop"] = _san(gc.get("META_UPGRADES"))
	out["boss_topdown"] = _san(gc.get("TOPDOWN_BOSSES"))
	out["vu_khi_max_cap"] = _san(gc.get("WEAPON_MAX"))
	out["boss_interval_s"] = _san(gc.get("BOSS_INTERVAL"))

	# Vùng (rút gọn: chỉ tên + ảnh nền, bỏ danh sách decor dài dòng)
	var stages_out := []
	for s in gc.get("STAGES"):
		stages_out.append({"name": _san(s.get("name")), "tile": _san(s.get("tile"))})
	out["khu_vuc_stage"] = stages_out

	# ---- 2) WEAPONS (const trong player.gd) ----
	var pl: GDScript = load("res://scripts/player.gd")
	out["vu_khi_chinh"] = _san(pl.get_script_constant_map().get("WEAPONS"))

	# ---- 3) Hằng số linh thú (familiar.gd) ----
	var fa: GDScript = load("res://scripts/familiar.gd")
	var fc := fa.get_script_constant_map()
	out["linh_thu_consts"] = {
		"CHARGE_TIME": _san(fc.get("CHARGE_TIME")),
		"NOVA_RADIUS": _san(fc.get("NOVA_RADIUS")),
		"NOVA_DAMAGE": _san(fc.get("NOVA_DAMAGE")),
	}

	# ---- 4) Quét biến/hằng vô hướng SỐ trong từng script ----
	var scalars := {}
	for key in SCALAR_SOURCES:
		scalars[key] = _scan_scalars(SCALAR_SOURCES[key])
	out["thong_so_so"] = scalars

	# ---- Ghi file ----
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Không mở được file để ghi: %s" % OUT_PATH)
		quit(1)
		return
	f.store_string(JSON.stringify(out, "\t", false))
	f.close()
	print("✓ Đã ghi: ", ProjectSettings.globalize_path(OUT_PATH))
	quit()


# Chuyển giá trị Godot sang dạng JSON-friendly (đệ quy)
func _san(v: Variant) -> Variant:
	match typeof(v):
		TYPE_DICTIONARY:
			var d := {}
			for k in v:
				d[str(k)] = _san(v[k])
			return d
		TYPE_ARRAY:
			var a := []
			for e in v:
				a.append(_san(e))
			return a
		TYPE_COLOR:
			return "Color(%.3f, %.3f, %.3f, %.3f)" % [v.r, v.g, v.b, v.a]
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return [v.x, v.y]
		TYPE_OBJECT:
			if v is Resource and v.resource_path != "":
				return v.resource_path
			return str(v)
		_:
			return v


# Quét các dòng "var/const NAME [: Type] := SỐ" ở mức class (không thụt đầu dòng)
func _scan_scalars(path: String) -> Dictionary:
	var fh := FileAccess.open(path, FileAccess.READ)
	if fh == null:
		return {}
	var txt := fh.get_as_text()
	fh.close()
	var re := RegEx.new()
	re.compile("^(?:var|const)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*(?::\\s*[A-Za-z0-9_]+\\s*)?:?=\\s*(-?[0-9]+\\.?[0-9]*)\\s*(?:#.*)?$")
	var res := {}
	for line in txt.split("\n"):
		var m := re.search(line)
		if m != null:
			var name := m.get_string(1)
			var num := m.get_string(2)
			res[name] = (float(num) if "." in num else int(num))
	return res
