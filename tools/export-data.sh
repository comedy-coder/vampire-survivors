#!/usr/bin/env bash
# Trích xuất thông số game từ scripts/*.gd ra JSON.
# Dùng:  ./tools/export-data.sh            (xuất ra game_data.json trong repo)
#        ./tools/export-data.sh ~/Desktop  (copy thêm bản ra thư mục chỉ định)
set -euo pipefail

# Về thư mục gốc repo (thư mục cha của tools/)
cd "$(dirname "$0")/.."

GODOT="${GODOT:-godot}"
if ! command -v "$GODOT" >/dev/null 2>&1; then
	echo "Không tìm thấy Godot. Đặt biến môi trường GODOT trỏ tới binary, ví dụ:" >&2
	echo "  GODOT=/opt/homebrew/bin/godot ./tools/export-data.sh" >&2
	exit 1
fi

echo "→ Đang trích xuất bằng Godot headless..."
"$GODOT" --headless --script tools/export_game_data.gd

OUT="$(pwd)/game_data.json"
echo "→ Xong: $OUT"

# Copy thêm ra thư mục tùy chọn (mặc định không copy)
if [[ $# -ge 1 ]]; then
	DEST="$1/vampire-survivors-data-auto.json"
	cp "$OUT" "$DEST"
	echo "→ Đã copy: $DEST"
fi
