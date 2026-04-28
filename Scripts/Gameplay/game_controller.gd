extends Node2D

@onready var player = $Player
@onready var UI = $UI
@onready var score_label = $UI/ScoreLabel
@onready var combo_label = $UI/ComboLabel
@onready var camera = $Camera2D

@onready var game_over_panel = $UI/GameOverPanel
@onready var final_score_label = $UI/GameOverPanel/FinalScore
@onready var name_edit = $UI/GameOverPanel/NameEdit
@onready var validate_button = $UI/GameOverPanel/ValidateButton

var leaf_scene = preload("res://Scenes/Gameplay/Leaf.tscn")
var active_leaves = []

var combo := 0
var pending_score := 0

var spawn_timer := 0.0
var spawn_interval := 2.0
var elapsed_time := 0.0

var game_over := false

var freeze_end_time := 0
var was_frozen := false


var cam_target_x := 640.0
var cam_zoom_target := Vector2.ONE
const CAM_MIN_ZOOM := 1.0
const CAM_MAX_ZOOM := 0.72

func _ready():
	randomize()
	player.landed.connect(_on_player_landed)
	update_ui()
	validate_button.pressed.connect(_on_validate_pressed)
	game_over_panel.visible = false
	camera.zoom = Vector2.ONE
	cam_target_x = player.global_position.x

func _process(delta):
	
	if was_frozen:
		if Time.get_ticks_msec() >= freeze_end_time:
			Engine.time_scale = 1.0
			was_frozen = false
		else:
			return
	handle_camera_follow(delta)
	
	if game_over:
		return
	
	elapsed_time += delta
	spawn_timer += delta
	check_keyboard_inputs()
	handle_spawning()

func handle_spawning():
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0

		var letter = random_letter()
		var x_pos = randf_range(120, 1160)

		spawn_leaf(letter, x_pos)

		var diff = difficulty_level()
		spawn_interval = lerp(2.5, 0.75, diff)

func spawn_leaf(letter:String, x_pos:float):
	var leaf = leaf_scene.instantiate()
	add_child(leaf)

	leaf.global_position = Vector2(x_pos, -330)
	leaf.set_letter(letter)
	var diff = difficulty_level()
	leaf.fall_speed = lerp(75, 175, diff) * randf_range(0.8, 1.2)
	# leaf.fall_speed = randi_range(75, 100)

	leaf.reached_ground.connect(_on_leaf_ground.bind(leaf))

	active_leaves.append(leaf)

func random_letter() -> String:
	var diff = difficulty_level()

	var easy_letters = "ASDKLQWE"
	var full_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	var pool = easy_letters if diff < 0.45 else full_letters

	var i = randi_range(0, pool.length() - 1)
	return pool[i]

func check_keyboard_inputs():
	for i in range(26):
		var letter = char(65 + i)
		var action = "type_" + letter.to_lower()

		if Input.is_action_just_pressed(action):
			try_cut_letter(letter)

func try_cut_letter(letter:String):
	var target_leaf = null
	var best_y = -99999.0
	for leaf in active_leaves:
		if is_instance_valid(leaf) and leaf.letter == letter:
			if leaf.global_position.y > best_y:
				best_y = leaf.global_position.y
				target_leaf = leaf
	if target_leaf != null:
		cut_leaf(target_leaf)
		return
	fail_combo()

func cut_leaf(leaf):
	active_leaves.erase(leaf)
	combo += 1
	pending_score += combo * 100
	player.dash_to(leaf.global_position)
	leaf.destroy_leaf()
	# spawn_score_popup(leaf.global_position, combo * 100)
	if combo >= 2:
		spawn_score_popup(
			leaf.global_position + Vector2(0, 28),
			combo,
			true
		)
	hit_freeze(0.06)
	update_ui()

func fail_combo():
	combo = 0
	pending_score = 0
	spawn_score_popup(
		player.global_position + Vector2(0, -100),
		combo,
		true
	)
	player.play_hurt()
	update_ui()

func _on_player_landed():
	if pending_score > 0:
		GameManager.add_score(pending_score)
		spawn_score_popup(
			player.global_position + Vector2(0, -70),
			pending_score
		)
	player.landing_success = pending_score > 0

	combo = 0
	pending_score = 0
	update_ui()

func _on_leaf_ground(leaf):
	active_leaves.erase(leaf)
	player.play_death()
	await player.sprite.animation_finished
	trigger_game_over()

func update_ui():
	score_label.text = "SCORE: " + str(GameManager.current_score)
	combo_label.text = "COMBO: " + str(combo)
	
func trigger_game_over():
	game_over = true

	final_score_label.text = "Score: " + str(GameManager.current_score)
	game_over_panel.visible = true

	if GameManager.is_highscore(GameManager.current_score):
		name_edit.visible = true
		validate_button.visible = true
	else:
		name_edit.visible = false
		validate_button.text = "Back To Menu"
		validate_button.visible = true

func _on_validate_pressed():
	if GameManager.is_highscore(GameManager.current_score):
		var player_name = name_edit.text.strip_edges()

		if player_name == "":
			player_name = "NONAME"

		GameManager.submit_score(player_name, GameManager.current_score)

	GameManager.return_to_menu()
	
func hit_freeze(duration:float):
	Engine.time_scale = 0.01
	was_frozen = true
	freeze_end_time = Time.get_ticks_msec() + int(duration * 1000.0)
	

		
	
func difficulty_level() -> float:
	return min(elapsed_time / 45.0, 1.0)
	
func handle_camera_follow(delta):
	var zone_center = 640.0
	var player_x = player.global_position.x

	var target_x = lerp(zone_center, player_x, 0.2)

	camera.global_position.x = lerp(
		camera.global_position.x,
		target_x,
		delta * 4.0
	)

	var distance = abs(player_x - zone_center)

	var zoom_factor = inverse_lerp(0.0, 520.0, distance)

	var zoom_value = lerp(1.0, 0.68, zoom_factor)

	camera.zoom = camera.zoom.lerp(
		Vector2(zoom_value, zoom_value),
		delta * 3.5
	)
	
func spawn_score_popup(pos:Vector2, value:int, is_combo := false):
	var scene = preload("res://Scenes/Components/ScorePopup.tscn")
	var popup = scene.instantiate()

	UI.add_child(popup)

	popup.position = pos
	popup.setup(value, is_combo)
