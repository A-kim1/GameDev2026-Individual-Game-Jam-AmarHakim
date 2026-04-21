extends CharacterBody2D

# Setting awal (settings)
@export var speed : float = 40
@export var gravity : float = 900
@export var chase_range : float = 120
@export var damage_to_player : int = 10
@export var attack_interval : float = 0.7
@export var knockback_force : float = 120
@export var max_health : int = 60
@export var points_reward: int = 20

signal enemy_died

# Variabel runtime (state)
var health : int
var player : CharacterBody2D

var is_chasing = false
var is_dead = false
var is_hurt = false
var player_in_range = false

@onready var anim = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var damage_area = $DamageToPlayer


# Setup awal
func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	attack_timer.wait_time = attack_interval
	
	# Area ini dipake buat deteksi kapan player masuk/keluar jangkauan hit
	damage_area.body_entered.connect(_on_damage_body_entered)
	damage_area.body_exited.connect(_on_damage_body_exited)


# Update physics per frame
func _physics_process(delta):
	if is_dead:
		return

	# Slime tetep kena gravitasi
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if not is_instance_valid(player):
		velocity.x = 0
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)
	# is_chasing jadi flag utama buat logic gerak + animasi
	is_chasing = distance < chase_range

	move_logic()
	handle_animation()
	move_and_slide()


func move_logic():
	if is_hurt:
		return

	if is_chasing:
		var direction = global_position.direction_to(player.global_position)
		# Slime cuma gerak horizontal
		velocity.x = direction.x * speed
		anim.flip_h = direction.x > 0
	else:
		velocity.x = 0


# Kena hit dari player (damage from player)

func take_damage(amount, source_position):
	if is_dead:
		return

	health -= amount
	print("Slime Health:", health)

	is_hurt = true
	anim.play("hit")

	var knock_dir = global_position.direction_to(source_position) * -1
	velocity = knock_dir * knockback_force

	if health <= 0:
		await get_tree().create_timer(0.2).timeout
		die()
		return

	await get_tree().create_timer(0.2).timeout
	is_hurt = false


func die():
	if is_dead:
		return

	is_dead = true
	
	# Stop semua logic damage biar gk hit pas udah mati
	player_in_range = false
	attack_timer.stop()
	damage_area.monitoring = false

	# Matikan collision biar slime gk ngahalang/kena hit lagi
	$CollisionShape2D.disabled = true
	$DamageToPlayer/CollisionShape2D.disabled = true

	velocity = Vector2.ZERO
	anim.play("death")

	GameManager.add_points(points_reward)

	await get_tree().create_timer(0.6).timeout

	emit_signal("enemy_died")
	queue_free()


# Ngedamage player (damage to player)

func _on_damage_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		_try_damage_player()
		attack_timer.start()


func _on_damage_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		attack_timer.stop()


func _on_attack_timer_timeout():
	_try_damage_player()


func _try_damage_player():
	if not player_in_range:
		return

	if not is_instance_valid(player):
		return

	if player.is_dead:
		return

	if player.is_invincible:
		return

	# Damage ke player cuma kalau semua syarat di atas lolos
	player.take_damage(damage_to_player, global_position)


# Logic animasi (animation)

func handle_animation():
	if is_dead:
		return

	if is_hurt:
		return

	if is_chasing:
		if anim.animation != "walk":
			anim.play("walk")
