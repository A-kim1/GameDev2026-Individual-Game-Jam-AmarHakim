extends Control
@onready var points_label = $points_now
@onready var total_label = $points_now2
@onready var highscore_label = $high_score

func _ready():
	get_tree().root.content_scale_factor = 1.0
	var current_score = GameManager.get_points()
	var escape_bonus = 500
	var total_score = current_score + escape_bonus
	
	# Update high score nya
	if total_score > Global.high_score:
		Global.high_score = total_score
	
	# Utk tampilan pointss sama highscore nya yg paling update
	points_label.text = "Points Earned: " + str(current_score)
	total_label.text = "Total Points: " + str(total_score)
	highscore_label.text = "High Score: " + str(Global.high_score)


func _on_button_pressed() -> void:
	SceneTransition.load_scene("res://Scenes/main_menu.tscn")
