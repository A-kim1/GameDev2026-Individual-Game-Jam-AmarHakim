extends Node

# Data global game (global state)
# Tempat nyimpen data yg kepake lintas scene

var current_wave: int
var moving_to_next_wave: bool

var high_score: int = 0
var current_score: int
var previous_score: int

const DIFFICULTY_EASY := "easy"
const DIFFICULTY_NORMAL := "normal"
const DIFFICULTY_HARD := "hard"

var skip_tutorial: bool = false
var selected_difficulty: String = DIFFICULTY_EASY
var wave_start_multiplier: int = 1

var player_health: int = -1


func set_skip_tutorial(value: bool) -> void:
	# Toggle dari stage select: ON artinya langsung skip tutorial
	skip_tutorial = value


func set_difficulty(difficulty: String) -> void:
	# Difficulty cuma ngaruh ke jumlah musuh awal per wave
	selected_difficulty = difficulty

	match difficulty:
		DIFFICULTY_NORMAL:
			wave_start_multiplier = 3
		DIFFICULTY_HARD:
			wave_start_multiplier = 5
		_:
			selected_difficulty = DIFFICULTY_EASY
			wave_start_multiplier = 1


func apply_wave_multiplier(base_wave_size: int) -> int:
	# Biar spawn minimal tetep 1 jadi wave gk mati
	return max(1, int(base_wave_size * wave_start_multiplier))
