extends Node2D

## リールが絵柄を切り替える間隔（回転中）
const REEL_TICK := 0.06
## リールごとの止まるタイミングのずれ（1番目→2番目→3番目の順に止まる）
const REEL_STAGGER := 0.35
## 一番早く止まるリールの回転時間
const REEL_SPIN_TIME := 0.7

var spins := 0
var wins := 0
var spinning := false

@onready var reels: Array[SlotSymbol] = [
	$HUD/Reels/Reel0, $HUD/Reels/Reel1, $HUD/Reels/Reel2,
]
@onready var spin_button: Button = $HUD/SpinButton
@onready var result_label: Label = $HUD/ResultLabel
@onready var spins_label: Label = $HUD/SpinsLabel
@onready var wins_label: Label = $HUD/WinsLabel


func _ready() -> void:
	spin_button.pressed.connect(_on_spin_pressed)
	for reel in reels:
		reel.show_symbol(randi() % SlotSymbol.SYMBOLS.size())
	_update_hud()


func _on_spin_pressed() -> void:
	if spinning:
		return
	spinning = true
	spin_button.disabled = true
	result_label.text = ""
	spins += 1
	_update_hud()

	var final_symbols: Array[int] = []
	for i in reels.size():
		final_symbols.append(randi() % SlotSymbol.SYMBOLS.size())
	for i in reels.size():
		_spin_reel(reels[i], REEL_SPIN_TIME + i * REEL_STAGGER, final_symbols[i])

	var total_time := REEL_SPIN_TIME + (reels.size() - 1) * REEL_STAGGER + 0.05
	await get_tree().create_timer(total_time).timeout
	_resolve_result(final_symbols)
	spinning = false
	spin_button.disabled = false


# 1本のリールを回す：一定時間はランダムに絵柄を切り替え続け、最後に final_index で止める
func _spin_reel(reel: SlotSymbol, duration: float, final_index: int) -> void:
	var t := 0.0
	while t < duration:
		reel.show_symbol(randi() % SlotSymbol.SYMBOLS.size())
		await get_tree().create_timer(REEL_TICK).timeout
		t += REEL_TICK
	reel.show_symbol(final_index)
	reel.bounce()


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
