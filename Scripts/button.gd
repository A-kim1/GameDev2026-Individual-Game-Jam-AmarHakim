extends Area2D

@onready var escape_menu = $"../escapeMenu"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player Masuk Button")
		escape_menu.show_menu()
