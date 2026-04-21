extends CanvasLayer

@onready var points_label: Label = %Label
@onready var skill_label: Label = %Label2

func _ready():
	GameManager.points_changed.connect(_on_points_changed)
	GameManager.skill_cooldown_changed.connect(_on_skill_cooldown_changed)
	
	# Label skill di awal2
	skill_label.text = "Skill Ready"

func _on_points_changed(new_points):
	points_label.text = "Points: " + str(new_points)

func _on_skill_cooldown_changed(time_left):
	if time_left > 0:
		skill_label.text = "Skill Cooldown: " + str(time_left)
	else:
		skill_label.text = "Skill Ready"
