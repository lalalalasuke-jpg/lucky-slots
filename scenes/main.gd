extends Node2D

## リールが絵柄を切り替える間隔（回転中）
const REEL_TICK := 0.06
## STOPを押し忘れても、この秒数たったら自動で止まる保険
const AUTO_STOP_TIME := 5.0

var spins := 0
var wins := 0
var spinning := false
# 各リールが今も回転中かどうか
var reel_spinning: Array[bool] = [false, false, false]

@onready var reels: Array[SlotSymbol] = [
	$HUD/Reels/Reel0, $HUD/Reels/Reel1, $HUD/Reels/Reel2,
]
@onready var stop_buttons: Array[Button] = [
	$HUD/StopButton0, $HUD/StopButton1, $HUD/StopButton2,
]
@onready var spin_button: Button = $HUD/SpinButton
@onready var result_label: Label = $HUD/ResultLabel
@onready var spins_label: Label = $HUD/SpinsLabel
@onready var wins_label: Label = $HUD/WinsLabel


func _ready() -> void:
	spin_button.pressed.connect(_on_spin_pressed)
	for i in stop_buttons.size():
		stop_buttons[i].pressed.connect(_on_stop_pressed.bind(i))
		stop_buttons[i].visible = false
	for reel in reels:
		reel.show_symbol(randi() % SlotSymbol.SYMBOLS.size())
	_update_hud()


func _on_spin_pressed() -> void:
	if spinning:
		return
	spinning = true
	spin_button.visible = false
	result_label.text = ""
	spins += 1
	_update_hud()

	for i in reels.size():
		reel_spinning[i] = true
		stop_buttons[i].disabled = false
		stop_buttons[i].visible = true
		_spin_reel(i)


# 目押し：タップされたリールを、今表示中の絵柄のまま止める
func _on_stop_pressed(i: int) -> void:
	reel_spinning[i] = false
	stop_buttons[i].disabled = true


# 1本のリールを回し続ける。reel_spinning[i] が false になるか、
# AUTO_STOP_TIME 秒たったら、その時点の絵柄で止まる
func _spin_reel(i: int) -> void:
	var reel := reels[i]
	var elapsed := 0.0
	while reel_spinning[i] and elapsed < AUTO_STOP_TIME:
		reel.show_symbol(randi() % SlotSymbol.SYMBOLS.size())
		await get_tree().create_timer(REEL_TICK).timeout
		elapsed += REEL_TICK
	reel_spinning[i] = false
	stop_buttons[i].disabled = true
	reel.bounce()
	_check_all_stopped()


func _check_all_stopped() -> void:
	for is_spinning in reel_spinning:
		if is_spinning:
			return
	for b in stop_buttons:
		b.visible = false
	var symbols: Array[int] = []
	for reel in reels:
		symbols.append(reel.symbol_index)
	_resolve_result(symbols)
	spinning = false
	spin_button.visible = true


func _resolve_result(symbols: Array[int]) -> void:
	if symbols[0] == symbols[1] and symbols[1] == symbols[2]:
		wins += 1
		var sym: Dictionary = SlotSymbol.SYMBOLS[symbols[0]]
		result_label.text = "WIN! (%s)" % sym.letter
		result_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	else:
		result_label.text = "try again"
		result_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.82))
	_update_hud()


func _update_hud() -> void:
	spins_label.text = "SPINS %d" % spins
	wins_label.text = "WINS %d" % wins
