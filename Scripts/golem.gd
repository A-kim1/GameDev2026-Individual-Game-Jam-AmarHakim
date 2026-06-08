extends CharacterBody2D

@export var speed : float = 50
@export var chase_range : float = 130
@export var damage_to_player : int = 20
@export var attack_interval : float = 0.7
@export var knockback_force : float = 20
@export var max_health : int = 120
@export var points_reward : int = 25

signal enemy_died

var health : int
var player : CharacterBody2D

var is_chasing = false
var is_dead = false
var is_attacking = false
var is_knockback = false
var player_in_range = false

@onready var anim = $AnimatedSprite2D
@onready var attack_fx = $AttackFX
@onready var attack_timer = $AttackTimer
@onready var damage_area = $DamageToPlayer


func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")

	attack_timer.wait_time = attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	damage_area.body_entered.connect(_on_damage_body_entered)
	damage_area.body_exited.connect(_on_damage_body_exited)

	attack_fx.visible = false
	anim.animation_finished.connect(_on_anim_finished)


func _physics_process(_delta):
	if is_dead:
		return

	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)
	is_chasing = distance < chase_range

	move_logic()
	handle_animation()

	move_and_slide()


func move_logic():
	if is_knockback:
		return

	if is_attacking:
		velocity = Vector2.ZERO
		return

	if is_chasing:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		anim.flip_h = direction.x < 0
		attack_fx.flip_h = anim.flip_h
	else:
		velocity = Vector2.ZERO


func take_damage(amount, source_position):
	if is_dead:
		return

	health -= amount

	var knock_dir = global_position.direction_to(source_position) * -1
	velocity = knock_dir * knockback_force

	is_knockback = true
	get_tree().create_timer(0.15).timeout.connect(func():
		is_knockback = false
	)

	if health <= 0:
		die()


func die():
	if is_dead:
		return

	is_dead = true
	player_in_range = false

	attack_timer.stop()
	damage_area.monitoring = false
	attack_fx.visible = false

	if $CollisionShape2D:
		$CollisionShape2D.disabled = true

	if damage_area and damage_area.get_node("CollisionShape2D2"):
		damage_area.get_node("CollisionShape2D2").disabled = true

	velocity = Vector2.ZERO
	anim.play("death")

	GameManager.add_points(points_reward)

	await get_tree().create_timer(1.0).timeout

	emit_signal("enemy_died")
	queue_free()


func _on_damage_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		if not is_attacking:
			_try_damage_player()
		attack_timer.start()


func _on_damage_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		attack_timer.stop()


func _on_attack_timer_timeout():
	if not is_attacking:
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

	is_attacking = true
	anim.play("attack")

	await get_tree().create_timer(0.5).timeout

	if is_dead or not is_attacking:
		return

	attack_fx.visible = true
	attack_fx.play("attack_fx")

	if player_in_range and is_instance_valid(player) and not player.is_dead and not player.is_invincible:
		player.take_damage(damage_to_player, global_position)


func _on_anim_finished():
	if anim.animation == "attack":
		is_attacking = false
		attack_fx.visible = false
		attack_fx.stop()


func handle_animation():
	if is_dead:
		return

	if is_attacking:
		return

	if player_in_range:
		return

	if is_chasing:
		if anim.animation != "chase":
			anim.play("chase")
	else:
		if anim.animation != "idle":
			anim.play("idle")
