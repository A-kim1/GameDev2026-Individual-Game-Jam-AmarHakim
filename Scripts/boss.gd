extends CharacterBody2D

# Setting awal (settings)
@export var speed : float = 45
@export var gravity : float = 900
@export var chase_range : float = 280
@export var attack_range : float = 120
@export var damage_to_player : int = 25
@export var attack_interval : float = 0.8
@export var attack_hit_start_frame : int = 8
@export var max_health : int = 250
@export var points_reward : int = 500
@export var hurt_time : float = 0.25
@export var post_hit_invincible_time : float = 0.2
@export var invincible_until_next_attack : bool = true

# Signal event
signal enemy_died

# Variabel runtime (state)
var health : int
var player : CharacterBody2D
var is_dead := false
var is_hurt := false
var is_attacking := false
var player_in_range := false
var attack_damage_window_open := false
var attack_has_hit := false
var can_take_damage := true
var pending_release_invincible_on_attack := false

@onready var anim = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var damage_area = $DamageToPlayer

# Camera shake
var camera2D : Camera2D
var cameraShakeNoise : FastNoiseLite

func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")

	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = true

	if is_instance_valid(player):
		# Biar body boss gk nahan body player gitu
		add_collision_exception_with(player)
		player.add_collision_exception_with(self)
		# DamageToPlayer area baca layer player yg aktif saat ini
		damage_area.collision_mask = player.collision_layer

	anim.play("idle")
	damage_area.monitoring = true
	damage_area.scale.x = 1
	can_take_damage = true
	pending_release_invincible_on_attack = false
	
	# Camera Shake
	camera2D = get_viewport().get_camera_2d()
	if camera2D == null:
		if is_instance_valid(player):
			camera2D = player.get_node_or_null("Camera2D")
		if camera2D == null:
			camera2D = get_node_or_null("/root/Root/Player/Camera2D")
	cameraShakeNoise = FastNoiseLite.new()

func startCameraShake(intensity : float):
	if not is_instance_valid(camera2D):
		camera2D = get_viewport().get_camera_2d()
	
	if not is_instance_valid(camera2D):
		return
		
	var cameraOffset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec() * intensity)
	camera2D.offset.x = cameraOffset
	camera2D.offset.y = cameraOffset
	
func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if not is_instance_valid(player) or player.is_dead:
		velocity.x = 0
		if not is_attacking and not is_hurt:
			anim.play("idle")
		move_and_slide()
		return

	if is_hurt:
		move_and_slide()
		return

	if not is_attacking:
		update_facing()

	var distance = global_position.distance_to(player.global_position)

	if is_attacking:
		velocity.x = 0
		update_attack_window()
	else:
		if distance <= attack_range:
			velocity.x = 0
			start_attack()
		elif distance <= chase_range:
			var direction = global_position.direction_to(player.global_position)
			velocity.x = direction.x * speed
			anim.play("walk")
		else:
			velocity.x = 0
			anim.play("idle")

	move_and_slide()


func update_facing():
	# Boss ini aslinya ngadep kiri, jadi dibalik kalau player ada di kanan.
	anim.flip_h = player.global_position.x > global_position.x
	damage_area.scale.x = -1 if anim.flip_h else 1


func start_attack():
	if is_dead or is_hurt or is_attacking:
		return

	# Invincible dilepas saat boss memulai serangan berikutnya.
	if pending_release_invincible_on_attack:
		pending_release_invincible_on_attack = false
		can_take_damage = true

	is_attacking = true
	attack_damage_window_open = false
	attack_has_hit = false
	anim.play("attack")
	update_attack_window()
	
	await get_tree().create_timer(1.5).timeout 
	# Camera Shake
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_method(startCameraShake, 100.0, 50.0, 0.2)


func update_attack_window():
	if anim == null or not is_instance_valid(anim):
		return

	if not is_attacking:
		return

	if anim.sprite_frames == null:
		return

	if not anim.sprite_frames.has_animation("attack"):
		return

	var attack_frame_count = anim.sprite_frames.get_frame_count("attack")
	var active_frame = clamp(attack_hit_start_frame, 0, max(attack_frame_count - 1, 0))
	attack_damage_window_open = anim.animation == "attack" and anim.frame >= active_frame

	if attack_damage_window_open and not attack_has_hit:
		_try_damage_player()


func _on_anim_frame_changed():
	if anim == null or not is_instance_valid(anim):
		return

	if anim.animation != "attack":
		return

	update_attack_window()


func _on_anim_animation_finished():
	if anim == null or not is_instance_valid(anim):
		return

	if anim.animation != "attack":
		return

	is_attacking = false
	attack_damage_window_open = false
	attack_has_hit = false
	attack_timer.stop()
	attack_timer.start()


func _on_attack_timer_timeout():
	if is_dead:
		return

	if player_in_range and not is_hurt and global_position.distance_to(player.global_position) <= attack_range + 12.0:
		start_attack()


func _on_damage_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		if attack_damage_window_open:
			_try_damage_player()


func _on_damage_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false


func _try_damage_player():
	if attack_has_hit:
		return

	if not player_in_range:
		return

	if not attack_damage_window_open:
		return

	if not is_instance_valid(player):
		return

	if player.is_dead:
		return

	if player.is_invincible:
		return

	player.take_damage(damage_to_player, global_position)
	attack_has_hit = true


func take_damage(amount, source_position):
	if is_dead or not can_take_damage:
		return

	health -= amount

	if health <= 0:
		die()
		return

	can_take_damage = false
	pending_release_invincible_on_attack = invincible_until_next_attack
	is_hurt = true
	is_attacking = false
	player_in_range = false
	attack_damage_window_open = false
	attack_has_hit = false
	attack_timer.stop()
	anim.play("hit")
	velocity.x = 0

	await get_tree().create_timer(hurt_time).timeout
	is_hurt = false

	if not invincible_until_next_attack:
		if post_hit_invincible_time > 0.0:
			await get_tree().create_timer(post_hit_invincible_time).timeout
		can_take_damage = true
		pending_release_invincible_on_attack = false
		return

	if post_hit_invincible_time > 0.0:
		await get_tree().create_timer(post_hit_invincible_time).timeout

func die():
	if is_dead:
		return

	is_dead = true
	is_attacking = false
	player_in_range = false
	attack_damage_window_open = false
	attack_has_hit = false
	can_take_damage = false
	pending_release_invincible_on_attack = false
	attack_timer.stop()
	damage_area.monitoring = false

	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	$DamageToPlayer/CollisionShape2D.disabled = true

	velocity = Vector2.ZERO
	anim.play("death")

	GameManager.add_points(points_reward)
	await anim.animation_finished

	emit_signal("enemy_died")
	queue_free()
