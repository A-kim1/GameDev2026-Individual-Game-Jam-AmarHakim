extends Control
@onready var points_label = $points_now
@onready var highscore_label = $high_score

func _ready():
	get_tree().root.content_scale_factor = 1.0
	var current_score = GameManager.get_points()
	
	if current_score > Global.high_score:
		Global.high_score = current_score
	
	points_label.text = "Score: " + str(current_score)
	highscore_label.text = "High Score: " + str(Global.high_score)


func _on_button_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/main_menu.tscn")
