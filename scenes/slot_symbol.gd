class_name SlotSymbol
extends Node2D

## 絵柄の一辺の長さ（正方形の枠）
const SIZE := 130.0

# 絵柄の一覧。画像を使わず、色つきの枠＋文字で表現
const SYMBOLS := [
	{"letter": "C", "color": Color("e74c3c")},
	{"letter": "B", "color": Color("2980b9")},
	{"letter": "$", "color": Color("27ae60")},
	{"letter": "X", "color": Color("9b59b6")},
	{"letter": "7", "color": Color("f1c40f")},
]

var symbol_index := 0
# 止まった瞬間だけ膨らませる演出用
var draw_scale := 1.0


func show_symbol(i: int) -> void:
	symbol_index = i
	queue_redraw()


# リールが止まった時の「ポンッ」という軽い演出
func bounce() -> void:
	draw_scale = 1.3
	var t := create_tween()
	t.tween_method(_set_draw_scale, 1.3, 1.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _set_draw_scale(v: float) -> void:
	draw_scale = v
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(draw_scale, draw_scale))
	var sym: Dictionary = SYMBOLS[symbol_index]
	var half := SIZE * 0.5
	var rect := Rect2(-half, -half, SIZE, SIZE)
	draw_rect(rect, Color(0.16, 0.16, 0.2), true)
	draw_rect(rect, sym.color, false, 4.0)

	var font := ThemeDB.fallback_font
	var font_size := 56
	var text: String = sym.letter
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, Vector2(-text_size.x * 0.5, text_size.y * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, sym.color)
