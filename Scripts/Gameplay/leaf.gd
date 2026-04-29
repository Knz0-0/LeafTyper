extends Area2D

signal reached_ground
signal destroyed

var letter : String = "A"
var fall_speed : float = 150.0
var ground_y : float = 620.0
var flash_timer := 0.0
var has_hit_ground := false

@onready var label = $LetterLabel
@onready var sprite = $AnimatedSprite2D

func _ready():
	label.text = letter
	sprite.play("default")

func _process(delta):
	position.y += fall_speed * delta
	update_danger_flash(delta)
	if global_position.y >= ground_y:
		reached_ground.emit()
		play_ground_impact()
		return

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
		if get_tree() == null:
			return
		await get_tree().process_frame
		if !is_inside_tree():
			return
		
		timer += get_process_delta_time()

		var t = timer / duration

		sprite.modulate.a = 1.0 - t
		label.scale = lerp(Vector2(1.7, 1.7), Vector2(2, 2), t)
		label.modulate.a = 1.0 - t
		
	queue_free()
	
func update_danger_flash(delta):
	var warning_start = ground_y - 180.0

	if global_position.y >= warning_start:
		flash_timer += delta * 10.0

		var pulse = sin(flash_timer)

		if pulse > 0:
			label.modulate = Color.RED
		else:
			label.modulate = Color.WHITE
	else:
		label.modulate = Color.WHITE
		flash_timer = 0.0
		
func play_ground_impact():
	if has_hit_ground:
		return

	has_hit_ground = true
	set_process(false)

	global_position.y = ground_y

	var duration = 0.20
	var timer = 0.0

	while timer < duration:
		if get_tree() == null:
			return
		await get_tree().process_frame
		if !is_inside_tree():
			return
		
		timer += get_process_delta_time()

		var t = timer / duration
		var eased = 1.0 - pow(1.0 - t, 3)

		sprite.modulate = Color(1, 1.0 - t, 1.0 - t, 1.0 - t)
		label.modulate = Color(1,1,1,1.0 - t)

		sprite.scale = Vector2(
			lerp(5.0, 5.45, eased),
			lerp(5.0, 5.55, eased)
		)

		label.scale = lerp(
			Vector2(1.7,1.7),
			Vector2(2.0,2.0),
			eased
		)

	queue_free()
