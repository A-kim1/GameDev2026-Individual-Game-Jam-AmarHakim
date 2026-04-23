extends Node2D

var bosses_alive = 0

@onready var right_boundary_collision = $RightBoundary/CollisionShape2D
@onready var portal = $Finish/portal
@onready var portal_anim = $Finish/portal/AnimatedSprite2D
@onready var portal_collision = $Finish/portal/CollisionShape2D
@onready var detect_player_area = $Finish/detectPlayer

func _ready():
	# Hitung boss yang ada di scene (boss dan boss2)
	var boss1 = get_node_or_null("boss")
	var boss2 = get_node_or_null("boss2")
	
	if boss1:
		bosses_alive += 1
		boss1.connect("enemy_died", Callable(self, "_on_boss_died"))
	if boss2:
		bosses_alive += 1
		boss2.connect("enemy_died", Callable(self, "_on_boss_died"))
		
	# Setup awal portal: hilangkan dari layar dan matikan collisionnya
	portal.visible = false
	portal_collision.set_deferred("disabled", true)
	
	# Connect signal dari area2D detectPlayer dan portal
	detect_player_area.connect("body_entered", Callable(self, "_on_detect_player_entered"))
	portal.connect("body_entered", Callable(self, "_on_portal_entered"))

func _on_boss_died():
	bosses_alive -= 1
	if bosses_alive <= 0:
		# Semua boss telah mati, hilangkan collision RightBoundary
		if right_boundary_collision:
			right_boundary_collision.set_deferred("disabled", true)

func _on_detect_player_entered(body):
	# Pastikan yang masuk adalah player, semua boss sudah mati, dan portal belum muncul
	if body.is_in_group("player") and bosses_alive <= 0 and not portal.visible:
		portal.visible = true
		portal_anim.play("open")
		# Tunggu animasi portal selesai memutar baru aktifkan portalnya
		await portal_anim.animation_finished
		portal_collision.set_deferred("disabled", false)

func _on_portal_entered(body):
	# Kalau player menyentuh portal yg sudah aktif, pindah ke layar win
	if body.is_in_group("player"):
		SceneTransition.load_scene("res://Scenes/you_win.tscn")
