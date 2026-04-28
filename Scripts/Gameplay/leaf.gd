extends Area2D

signal reached_ground
signal destroyed

var letter : String = "A"
var fall_speed : float = 150.0
var ground_y : float = 620.0

@onready var label = $LetterLabel
@onready var sprite = $AnimatedSprite2D

func _ready():
	label.text = letter
	sprite.play("default")

func _process(delta):
	position.y += fall_speed * delta
	
	if global_position.y >= ground_y:
		reached_ground.emit()
		queue_free()

func set_letter(value:String):
	letter = value
	
	if is_node_ready():
		label.text = letter

func destroy_leaf():
	destroyed.emit()
	play_cut_effect()
	
func play_cut_effect():
	set_process(false)
	sprite.stop()
	sprite.modulate = Color(1.4, 1.3, 1.1)
	rotation_degrees = randf_range(-20, 20)

	var duration = 0.9
	var timer = 0.0

	while timer < duration:
		await get_tree().process_frame
		timer += get_process_delta_time()

		var t = timer / duration

		sprite.modulate.a = 1.0 - t
		label.scale = lerp(Vector2(1.7, 1.7), Vector2(2, 2), t)
		label.modulate.a = 1.0 - t
		
	queue_free()
