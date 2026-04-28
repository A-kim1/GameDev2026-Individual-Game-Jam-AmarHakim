extends CharacterBody2D

# Setting awal (settings)
@export var walk_speed = 120.0
@export var run_speed = 200.0
@export var jump_force = -280.0
@export var gravity = 900.0
@export var max_jumps = 2

@export var attack_damage : int = 20
@export var attack_duration : float = 0.3
@export var knockback_force : float = 180
@export var invincible_time : float = 0.4

@export var max_health : int = 100

@export var skill_cooldown : float = 8.0
@export var skill_damage : int = 35

# Variabel runtime (state)
var jump_count = 0
var is_attacking = false
var is_dead = false
var is_hurt = false
var is_invincible = false

var health : int

@onready var anim = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox

var hit_enemies := []

var facing_right := true
var attack_offset_x : float

var can_use_skill := true

@onready var skill_pivot = $SkillPivot
@onready var skill_slash = $SkillPivot/SkillSlash
@onready var skill_anim = $SkillPivot/SkillSlash/AnimationPlayer

func _ready():
	if Global.player_health != -1:
		health = Global.player_health
	else:
		health = max_health
		
	attack_hitbox.monitoring = false
	attack_hitbox.collision_mask = 1
	skill_slash.monitoring = false
	skill_slash.visible = false
	add_to_group("player")
	attack_offset_x = attack_hitbox.position.x

func _physics_process(delta):
	if is_dead:
		return

	# Kalau jatuh terlalu bawah, anggap mati aja langsung
	if position.y >= 650:
		SceneTransition.death_scene()

	apply_gravity(delta)
	handle_input()
	handle_animation()

	move_and_slide()

# Input gerak + attack + skill

func handle_input():
	if is_hurt:
		return

	var direction = Input.get_axis("left", "right")

	# Kalau lagi attack tapi player jalan, attack langsung dibatalin
	if is_attacking and direction != 0:
		cancel_attack()

	# Logic jalan / lari
	var speed = walk_speed
	if Input.is_action_pressed("run"):
		speed = run_speed

	velocity.x = direction * speed

	if direction != 0:
		facing_right = direction > 0
		anim.flip_h = not facing_right

		# Biar hitbox attack ngadep arah yg sama sama player
		attack_hitbox.scale.x = 1 if facing_right else -1

		# Pivot skill ikut dibalik juga biar slash ke arah yg benar
		skill_pivot.scale.x = 1 if facing_right else -1


	# Double jump dibatasi pakai jump_count
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_force
		jump_count += 1


	# Attack basic
	if Input.is_action_just_pressed("attack"):
		start_attack()


	# Skill aktif kalau cooldown udah selesai
	if Input.is_action_just_pressed("skill"):
		use_skill()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Nyentuh lantai = reset jatah lompat nya
		jump_count = 0


# Logic attack (attack system)

func start_attack():

	if is_attacking:
		return

	is_attacking = true
	# List ini biar 1 musuh gk kena hit berkali-kali dlm 1 ayunan gituu
	hit_enemies.clear()

	anim.play("attack")
	attack_hitbox.monitoring = true

	await get_tree().create_timer(attack_duration).timeout

	if is_attacking: # kalau belum di cancel
		finish_attack()

func finish_attack():
	attack_hitbox.monitoring = false
	is_attacking = false

func cancel_attack():
	attack_hitbox.monitoring = false
	is_attacking = false
	anim.stop()

func _on_attack_hitbox_area_entered(area):
	var enemy = area.get_parent()

	if enemy == self:
		return

	if enemy.has_method("take_damage") and not enemy in hit_enemies:
		hit_enemies.append(enemy)
		enemy.take_damage(attack_damage, global_position)
		
func use_skill():
	if not can_use_skill:
		return

	can_use_skill = false

	# Aktifin area damage skill selama animasi skill nya itu jalan
	skill_slash.visible = true
	skill_slash.monitoring = true
	
	# Mainin anim sprite slash nya
	skill_slash.get_node("AnimatedSprite2D").play("skill")

	# Mainin anim gerak slash ke depan
	skill_anim.play("new_animation")

	await skill_anim.animation_finished

	skill_slash.monitoring = false
	skill_slash.visible = false

	skill_anim.stop()
	skill_anim.seek(0, true)

	var time_left = skill_cooldown

	# Emit tiap 1 detik biar HUD bisa update countdown skill
	while time_left > 0:
		GameManager.skill_cooldown_changed.emit(time_left)
		await get_tree().create_timer(1.0).timeout
		time_left -= 1

	GameManager.skill_cooldown_changed.emit(0)
	can_use_skill = true


# Logic kena damage (damage system)

func take_damage(amount, source_position):
	if is_dead or is_invincible:
		return

	health -= amount
	print("Player Health:", health)

	is_hurt = true
	is_invincible = true

	anim.play("hit")

	var knock_dir = global_position.direction_to(source_position) * -1
	velocity = knock_dir * knockback_force

	# Hurt state sebentar supaya player gk bisa langsung kontrol penuh
	get_tree().create_timer(0.2).timeout.connect(func():
		is_hurt = false
	)

	# I-frame: beberapa saat gk bisa kena hit lagi
	get_tree().create_timer(invincible_time).timeout.connect(func():
		is_invincible = false
	)

	if health <= 0:
		die()

func die():
	is_dead = true
	anim.play("death")
	await get_tree().create_timer(0.3).timeout
	SceneTransition.death_scene()


# Logic animasi nya (animation)

func handle_animation():
	if is_dead:
		return

	if is_hurt:
		return

	if is_attacking:
		return

	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
			if jump_count > 1:
				anim.play("doubleJump")
		else:
			anim.play("fall")
		return

	if velocity.x != 0:
		anim.play("run")
	else:
		anim.play("idle")
