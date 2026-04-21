extends Area2D

@export var damage : int = 35

func _ready():
	monitoring = false
	area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	var enemy = area.get_parent()

	if enemy.is_in_group("player"):
		return

	if enemy.has_method("take_damage"):
		enemy.take_damage(damage, global_position)
