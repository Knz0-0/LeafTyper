extends Node2D

@onready var player = $Player
@onready var UI = $UI
@onready var score_label = $UI/ScoreLabel
@onready var combo_label = $UI/ComboLabel
@onready var camera = $Camera2D
@onready var death_fade = $UI/DeathFade

@onready var game_over_panel = $UI/GameOverPanel
@onready var final_score_label = $UI/GameOverPanel/FinalScore
@onready var name_edit = $UI/GameOverPanel/NameEdit
@onready var validate_button = $UI/GameOverPanel/ValidateButton
@onready var play_again_button = $UI/GameOverPanel/PlayAgainButton

@onready var parallax_layer = $ParallaxBG/SkyLayer
@onready var parallax_layer2 = $ParallaxBG/SkyLayer2
@onready var parallax_layer3 = $ParallaxBG/SkyLayer3
@onready var parallax_layer4 = $ParallaxBG/SkyLayer4
@onready var parallax_layer5 = $ParallaxBG/SkyLayer5
@onready var parallax_layer6 = $ParallaxBG/SkyLayer6
var layer2_base_y
var layer3_base_y
var layer4_base_y
var layer5_base_y
var layer6_base_y

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

var bg_time := 0.0

func _ready():
	randomize()
	player.landed.connect(_on_player_landed)
	update_ui()
	validate_button.pressed.connect(_on_validate_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	game_over_panel.visible = false
	camera.zoom = Vector2.ONE
	cam_target_x = player.global_position.x
	MusicManager.play_game()
	layer2_base_y = parallax_layer2.position.y
	layer3_base_y = parallax_layer3.position.y
	layer4_base_y = parallax_layer4.position.y
	layer5_base_y = parallax_layer5.position.y
	layer6_base_y = parallax_layer6.position.y

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
	bg_time += delta
	update_parallax_bob()
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
	var dash_dir = (leaf.global_position - player.global_position).normalized()
	player.dash_to(leaf.global_position)
	spawn_cut_particles(leaf.global_position, dash_dir)
	leaf.destroy_leaf()
	if combo >= 2:
		spawn_score_popup(
			leaf.global_position + Vector2(0, 28),
			combo,
			true
		)
	var pitch_bonus = min(combo * 0.025, 0.30)
	if combo <= 3:
		SoundManager.play_sfx("slash", -8, pitch_bonus)
	elif combo <= 6:
		hit_freeze(0.05)
		SoundManager.play_sfx("clash", -8, pitch_bonus)
	elif combo <= 9:
		hit_freeze(0.08)
		SoundManager.play_sfx("tung", -8, pitch_bonus)
	else:
		hit_freeze(0.1)
		SoundManager.play_sfx("epic", -8, pitch_bonus)
	
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
	# SoundManager.play_sfx("tung")
	update_ui()

func _on_player_landed():
	spawn_landing_particles(player.global_position)
	if pending_score > 0:
		GameManager.add_score(pending_score)
		SoundManager.play_sfx("score_up1")
		spawn_score_popup(
			player.global_position + Vector2(0, -70),
			pending_score
		)
	player.landing_success = pending_score > 0

	combo = 0
	pending_score = 0
	update_ui()

func _on_leaf_ground(leaf):
	if game_over:
		return
	game_over = true
	active_leaves.erase(leaf)
	SoundManager.play_sfx("game_over")
	player.play_death()
	await player.sprite.animation_finished
	trigger_game_over()

func update_ui():
	score_label.text = "SCORE: " + str(GameManager.current_score)
	combo_label.text = "COMBO: " + str(combo)
	
func trigger_game_over():
	MusicManager.fade_to_game_over()
	game_over = true
	await play_death_fade()

	final_score_label.text = "Score: " + str(GameManager.current_score)
	game_over_panel.visible = true

	if GameManager.is_highscore(GameManager.current_score):
		name_edit.visible = true
		validate_button.visible = true
	else:
		name_edit.visible = false
		validate_button.text = "Back To Menu"
		validate_button.visible = true

func play_death_fade():
	var duration = 0.8
	var timer = 0.0

	while timer < duration:
		await get_tree().process_frame
		timer += get_process_delta_time()

		var t = timer / duration
		death_fade.color.a = lerp(0.0, 0.72, t)

func _on_validate_pressed():
	if GameManager.is_highscore(GameManager.current_score):
		var player_name = name_edit.text.strip_edges()

		if player_name == "":
			player_name = "NONAME"

		GameManager.submit_score(player_name, GameManager.current_score)
	await TransitionManager.play_transition()
	GameManager.return_to_menu()

func _on_play_again_pressed():
	if GameManager.is_highscore(GameManager.current_score):
		var player_name = name_edit.text.strip_edges()

		if player_name == "":
			player_name = "NONAME"

		GameManager.submit_score(player_name, GameManager.current_score)
	GameManager.start_game()
	
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

func spawn_cut_particles(pos:Vector2, dir:Vector2):
	var p = preload("res://Scenes/Components/CutParticles.tscn").instantiate()

	add_child(p)
	p.global_position = pos

	p.rotation = dir.angle()

	p.emitting = true


func spawn_landing_particles(pos:Vector2):
	var p = preload("res://Scenes/Components/LandingParticles.tscn").instantiate()

	add_child(p)
	p.global_position = pos
	p.emitting = true
	
func update_parallax_bob():
	parallax_layer2.motion_offset.y = sin(bg_time * 0.22 + 0.4) * 8 \
	+ sin(bg_time * 0.51) * 2
	parallax_layer3.motion_offset.y = sin(bg_time * 0.28 + 1.1) * 12 \
	+ sin(bg_time * 0.63) * 3
	parallax_layer4.motion_offset.y = sin(bg_time * 0.35 + 2.0) * 16 \
	+ sin(bg_time * 0.74) * 4
	parallax_layer5.motion_offset.y = sin(bg_time * 0.43 + 0.8) * 22 \
	+ sin(bg_time * 0.92) * 5
	parallax_layer6.motion_offset.y = sin(bg_time * 0.55 + 1.7) * 28 \
	+ sin(bg_time * 1.15) * 6
