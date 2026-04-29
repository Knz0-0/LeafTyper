extends Button

var base_min_size := Vector2.ZERO
var target_width := 0.0
var hover := false

func _ready():
	base_min_size = custom_minimum_size
	target_width = base_min_size.x

	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)

func _process(delta):
	var wanted = base_min_size.x

	if hover:
		wanted = base_min_size.x * 1.18

	target_width = lerp(target_width, wanted, delta * 12.0)

	custom_minimum_size.x = target_width

func _on_hover_enter():
	hover = true
	SoundManager.play_sfx("interface_hover", -16)

func _on_hover_exit():
	hover = false
