extends Control

# Setup awal (init)
func _ready():
	get_tree().root.content_scale_factor = 1.0
	GameManager.reset_points()


# Aksi tombol menu nya (menu action)
func _on_start_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/tutorial.tscn")

func _on_stage_select_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/stage_select.tscn")
	
func _on_credit_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/credit.tscn")
	
func _on_exit_pressed() -> void:
	get_tree().quit()
