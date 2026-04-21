extends Area2D
@onready var game_manager: Node = %GameManager
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# COIN PICKUP
func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Mainin anim dulu biar pickup terasa lebih halus
		anim.play("pick")
		await anim.animation_finished
		GameManager.add_points(5)
		queue_free()
