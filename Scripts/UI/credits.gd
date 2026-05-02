extends Control

var scroll_speed := 20.0
var current_speed := 20.0

var stop_y := -1400.0 
var slowing := false

@onready var back_button = $BackButton
@onready var credits_text = $CreditsText


func _ready() -> void:
	credits_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_text.position = Vector2(0, get_viewport_rect().size.y)
	credits_text.size = Vector2(get_viewport_rect().size.x, 2000)
	credits_text.bbcode_enabled = true
	back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(func():
		SoundManager.play_sfx("interface_hover")
	)
	


func _process(delta):
	if not slowing:
		credits_text.position.y -= current_speed * delta

		if credits_text.position.y <= stop_y:
			slowing = true
	else:
		current_speed = lerp(current_speed, 0.0, delta * 2.5)
		credits_text.position.y -= current_speed * delta


func _on_back_pressed():
	SoundManager.play_sfx("clash")
	GameManager.return_to_menu()
