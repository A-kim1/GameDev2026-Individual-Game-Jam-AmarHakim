extends Node2D

# Setup awal level (init)
func _ready():
	get_tree().root.content_scale_factor = 5.0
	GameManager.reset_points()
	_apply_difficulty_to_spawners()


func _apply_difficulty_to_spawners() -> void:
	# Ambil pengali (multiplier) difficulty dari Stage Select (Easy=1, Normal=3, Hard=5)
	var multiplier := Global.wave_start_multiplier

	for child in get_children():
		# Biar simpel, aku cuman lihat node EnemySpawner nya aja
		if not child.name.begins_with("EnemySpawner"):
			continue

		var base_wave_size = child.get("start_wave_size")
		# Safety check biar aman kalau ada node aneh/gk punya properti ini
		if base_wave_size is int:
			
			# Intinya: utk ubah nilai start_wave_size di spawner nya
			# Contoh: base 2, Hard(5x) jadi 10
			child.set("start_wave_size", base_wave_size * multiplier)
