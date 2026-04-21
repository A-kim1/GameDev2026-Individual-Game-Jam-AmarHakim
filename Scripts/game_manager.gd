extends Node

# Ngurus score + cooldown skill (game manager)
# Intinya: script global utk ngurus poin + status cooldown skill

signal points_changed(new_points)
signal skill_cooldown_changed(time_left)

var points : int = 0

func add_points(amount: int):
	# Tiap dapet poin, langsung update ke UI
	points += amount
	points_changed.emit(points)

func reset_points():
	# Kepake pas mulai run baru
	points = 0
	points_changed.emit(points)

func get_points():
	return points
