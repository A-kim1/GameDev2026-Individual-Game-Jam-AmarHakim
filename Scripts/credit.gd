extends Control

func _ready():
	get_tree().root.content_scale_factor = 1.0


func _on_main_menu_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/main_menu.tscn")
