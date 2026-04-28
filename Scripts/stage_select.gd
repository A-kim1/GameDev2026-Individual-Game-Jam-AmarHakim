extends Control

@onready var button_skip_tutorial: Button = $ButtonSkipT
@onready var button_easy: Button = $Easy
@onready var button_normal: Button = $Normal
@onready var button_hard: Button = $Hard
@onready var button_go_back: Button = $GoBack

# Setup awal (init)
func _ready():
	get_tree().root.content_scale_factor = 1.0

	# Bikin tombol skip tutorial yg mode nya itu toggle, bukan sekali klik doang
	# Pressed = true dan not pressed = false
	button_skip_tutorial.toggle_mode = true
	# Set false dulu krn di global nya itu false (off)
	button_skip_tutorial.button_pressed = Global.skip_tutorial
	_update_skip_tutorial_button_text()


# Toggle skip tutorial (pas button nya dipencet jalanin fungsi ini yg set global var nya dan update label nya)
func _on_skip_tutorial_toggled(is_pressed: bool) -> void:
	Global.set_skip_tutorial(is_pressed)
	_update_skip_tutorial_button_text()

# Ini cuman buat update tampilan label nya doang
func _update_skip_tutorial_button_text() -> void:
	if Global.skip_tutorial:
		button_skip_tutorial.text = "SKIP TUTORIAL: ON"
	else:
		button_skip_tutorial.text = "SKIP TUTORIAL: OFF"


# Pilih difficulty
func _on_easy_pressed() -> void:
	_start_game_with_difficulty(Global.DIFFICULTY_EASY)


func _on_normal_pressed() -> void:
	_start_game_with_difficulty(Global.DIFFICULTY_NORMAL)


func _on_hard_pressed() -> void:
	_start_game_with_difficulty(Global.DIFFICULTY_HARD)

# Logic utama yg nentuin difficulity yg player pilih sekarang
func _start_game_with_difficulty(difficulty: String) -> void:
	# Simpan pilihan difficulty dulu, biar level_1 bisa baca nilainya
	Global.set_difficulty(difficulty)
	Global.player_health = -1

	# Kalau skip ON langsung ke level, kalau OFF masuk tutorial dulu
	if Global.skip_tutorial:
		SceneTransition.load_scene("res://Scenes/level_1.tscn")
	else:
		SceneTransition.load_scene("res://Scenes/tutorial.tscn")


# Navigasi balik ke scene main menu
func _on_go_back_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/main_menu.tscn")
