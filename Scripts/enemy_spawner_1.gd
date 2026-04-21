extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_delay: float = 1.0
@export var start_wave_size: int = 2
@export var wave_multiplier: float = 1.5

var current_wave: int = 0
var enemies_alive: int = 0
var is_spawning: bool = false
var is_waiting_next_wave: bool = false

var spawn_points: Array = []


func _ready():

	# Cari semua Marker2D (ini itu lebih aman gituu)
	spawn_points = find_children("", "Marker2D", true, false)

	$Area2D.body_entered.connect(_on_area_body_entered)


# Trigger area (trigger)

func _on_area_body_entered(body):
	# Wave pertama dimulai pas player masuk area
	if body.is_in_group("player") and not is_spawning and current_wave == 0:
		start_next_wave()


# Sistem wave musuh (wave system)

func start_next_wave():
	if is_spawning:
		return

	is_spawning = true
	current_wave += 1

	# Rumus jumlah musuh per wave
	var amount = int(start_wave_size * pow(wave_multiplier, current_wave - 1))
	print(name, "Wave:", current_wave, "Spawn:", amount)
	await spawn_wave(amount)
	is_spawning = false


func spawn_wave(amount):
	# Spawn satu-satu biar gk numpuk di frame yg sama
	for i in amount:
		spawn_enemy()
		await get_tree().create_timer(spawn_delay).timeout


func spawn_enemy():
	if spawn_points.is_empty():
		return

	var spawn_point = spawn_points.pick_random()
	print("Spawn at:", spawn_point.name, spawn_point.global_position)
	var enemy = enemy_scene.instantiate()

	# Spawn ke level root biar enemy bebas gerak di area level
	get_parent().add_child(enemy)
	enemy.global_position = spawn_point.global_position
	enemies_alive += 1
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))


func _on_enemy_died():
	enemies_alive -= 1

	if enemies_alive <= 0 and not is_waiting_next_wave:
		is_waiting_next_wave = true
		
		# Kasih jeda sebentar sebelum wave berikutnya
		await get_tree().create_timer(2.0).timeout
		
		is_waiting_next_wave = false
		start_next_wave()
