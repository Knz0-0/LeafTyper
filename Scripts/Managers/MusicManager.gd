extends Node

var player : AudioStreamPlayer

var menu_music = preload("res://Assets/Audio/Music/GoT_menu_flute.ogg")
var game_music = preload("res://Assets/Audio/Music/japan.ogg")
var game_over_music = preload("res://Assets/Audio/Music/sad_flute.ogg")

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

	player.bus = "Master"
	player.volume_db = -25
	player.stream = menu_music
	player.play()

func play_menu():
	if player.stream != menu_music:
		player.stop()
		player.stream = menu_music
	
	player.volume_db = -25
	
	if not player.playing:
		player.play()

func play_game():
	if player.stream != game_music:
		player.stop()
		player.stream = game_music

	player.volume_db = -20

	if not player.playing:
		player.play()

func stop_music():
	player.stop()
	
func fade_to_game_over():
	await fade_out_music()

	player.stream = game_over_music
	player.play()

	await fade_in_music()
	
func fade_out_music():
	var start_db = player.volume_db
	var duration = 0.8
	var timer = 0.0

	while timer < duration:
		await get_tree().process_frame
		timer += get_process_delta_time()

		var t = timer / duration
		player.volume_db = lerp(start_db, -40.0, t)

func fade_in_music():
	var duration = 1.2
	var timer = 0.0

	player.volume_db = -40.0

	while timer < duration:
		await get_tree().process_frame
		timer += get_process_delta_time()

		var t = timer / duration
		player.volume_db = lerp(-40.0, -10.0, t)
	
