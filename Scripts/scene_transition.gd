extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

# Setup awal (init)
func _ready() -> void:
	color_rect.visible = false

# Transisi scene (scene transition)
# Utk pindah ke scene tujuan pakai fade biasa
func load_scene(target_scene: String):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		Global.player_health = players[0].health
		
	animation_player.play("fade")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target_scene)
	animation_player.play_backwards("fade")

# Utk reload scene aktif (restart level)
func reload_scene():
	Global.player_health = -1
	animation_player.play("fade")
	await animation_player.animation_finished
	get_tree().reload_current_scene()
	animation_player.play_backwards("fade")

# Utk transisi pas player mati
func death_scene():
	Global.player_health = -1
	animation_player.play("fade_death")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/you_died.tscn")
	animation_player.play_backwards("fade_death")
