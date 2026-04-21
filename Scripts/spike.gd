extends Node2D

# Setting awal (settings)
@export var damage := 20
@export var delay_before_activate := 0.5
@export var active_time := 1.0
@export var cooldown_time := 1.0

# Variabel runtime (state)
var can_trigger := true

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var trigger = $Trigger


# Setup awal trap nya
func _ready():
	anim.play("idle")
	hitbox.monitoring = false
	
	# Trigger buat mulai siklus trap, hitbox buat ngedamage
	trigger.body_entered.connect(_on_trigger_entered)
	hitbox.body_entered.connect(_on_hitbox_entered)


# Pas player masuk area trigger, trap mulai aktif
func _on_trigger_entered(body):
	if body.is_in_group("player") and can_trigger:
		start_delay()


# Delay kecil sebelum duri nya itu kluar
func start_delay():
	can_trigger = false
	
	await get_tree().create_timer(delay_before_activate).timeout
	
	activate_trap()


# Trap aktif, hitbox nyala
func activate_trap():
	anim.play("trap")
	hitbox.monitoring = true
	
	await get_tree().create_timer(active_time).timeout
	
	deactivate_trap()


# Trap balik idle dan masuk cooldown
func deactivate_trap():
	anim.play("idle")
	hitbox.monitoring = false
	
	await get_tree().create_timer(cooldown_time).timeout
	
	can_trigger = true


# Damage cuma saat hitbox aktif dan player nyentuh
func _on_hitbox_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, global_position)
