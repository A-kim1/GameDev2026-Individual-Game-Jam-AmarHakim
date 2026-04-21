extends CharacterBody2D

# Setting awal (settings)
@export var speed : float = 60
@export var chase_range : float = 200
@export var attack_range : float = 50
@export var damage_to_player : int = 15
@export var attack_interval : float = 1.0
@export var max_health : int = 40
@export var points_reward : int = 15
@export var knockback_force : float = 150
@export var hurt_time : float = 0.2

# Signal event
signal enemy_died

# Variabel runtime (state)
var health : int
var player : CharacterBody2D
var is_dead := false
var is_attacking := false
var is_hurt := false

@onready var anim = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var damage_area = $DamageToPlayer


# Setup awal
func _ready():
	health = max_health
	
	player = get_tree().get_first_node_in_group("player")
	
	attack_timer.wait_time = attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	damage_area.body_entered.connect(_on_damage_body_entered)
	
	anim.play("move")

# Update physics per frame
func _physics_process(delta):

	if is_dead:
		return
	
	if is_hurt:
		move_and_slide()
		return
	
	if not is_instance_valid(player):
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	# Kalau player masuk radius, bat mulai ngejar
	if distance <= chase_range:
		chase_player()
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func chase_player():
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	
	anim.flip_h = direction.x > 0
	
	# Kalau udah deket, masuk mode attack nya
	if global_position.distance_to(player.global_position) <= attack_range:
		start_attack()


# Logic attack
func start_attack():
	if is_attacking:
		return
	
	is_attacking = true
	anim.play("attack")
	attack_timer.start()


func _on_attack_timer_timeout():
	is_attacking = false
	anim.play("move")


func _on_damage_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage_to_player, global_position)


# Kena hit dari player (damage from player)
func take_damage(amount, source_position):
	if is_dead:
		return
	
	health -= amount
	
	is_hurt = true
	anim.play("hit")
	
	# arah knockback berlawanan dari sumber damage
	var knock_dir = global_position.direction_to(source_position) * -1
	velocity = knock_dir * knockback_force
	
	await get_tree().create_timer(hurt_time).timeout
	is_hurt = false
	
	if health <= 0:
		die()


func die():
	is_dead = true
	
	anim.play("death")
	GameManager.add_points(points_reward)
	
	await get_tree().create_timer(0.6).timeout
	
	emit_signal("enemy_died")
	queue_free()
