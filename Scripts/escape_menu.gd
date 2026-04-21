extends Node

@onready var panel = $Panel
@onready var yes_button = $Panel/VBoxContainer/yes
@onready var no_button = $Panel/VBoxContainer/no

func _ready():
	panel.hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)


func show_menu():
	panel.show()
	get_tree().paused = true


func _on_yes_pressed():
	get_tree().paused = false
	#SceneTransition.load_scene("res://Scenes/you_win.tscn")
	SceneTransition.load_scene("res://Scenes/boss_level.tscn")


func _on_no_pressed():
	panel.hide()
	get_tree().paused = false
