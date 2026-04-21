extends ProgressBar

var parent_character

func _ready():
	parent_character = get_parent()
	max_value = parent_character.max_health
	value = parent_character.health

func _process(delta):
	if parent_character == null:
		return

	value = parent_character.health
	
	# sembunyi kalau full
	visible = value < max_value
