extends Area2D

@export var damage_to_player : int = 5

# Setup awal
func _ready():
	body_entered.connect(_on_body_entered)

# Logic pas ada body masuk area bird
func _on_body_entered(body):

	if body.is_in_group("player"):
		
		# Pastiin player punya fungsi take_damage
		if body.has_method("take_damage"):
			# Bird kasih damage ke player
			body.take_damage(damage_to_player, global_position)
