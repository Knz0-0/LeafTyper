extends Node

var sounds = {}

func _ready():
	sounds["slash"] = preload("res://Assets/Audio/SFX/sword_slash.wav")
	sounds["clash"] = preload("res://Assets/Audio/SFX/sword_clash.wav")
	sounds["epic"] = preload("res://Assets/Audio/SFX/sword_epic.wav")
	sounds["ting"] = preload("res://Assets/Audio/SFX/sword_ting.wav")
	sounds["tung"] = preload("res://Assets/Audio/SFX/sword_tung.wav")
	sounds["hurt"] = preload("res://Assets/Audio/SFX/hurt.wav")
	sounds["land"] = preload("res://Assets/Audio/SFX/land1.wav")
	
	sounds["score_up1"] = preload("res://Assets/Audio/SFX/score_up.wav")
	sounds["score_up2"] = preload("res://Assets/Audio/SFX/score_up2.wav")
	sounds["skin_select"] = preload("res://Assets/Audio/SFX/skin_select.wav")
	
	sounds["game_over"] = preload("res://Assets/Audio/SFX/game_over.wav")
	sounds["interface_hover"] = preload("res://Assets/Audio/SFX/interface_hover.wav")

func play_sfx(name:String, volume_db := -8.0, pitch_bonus := 0.0):
	if not sounds.has(name):
		return

	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = sounds[name]
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.98, 1.02) + pitch_bonus

	player.finished.connect(player.queue_free)

	player.play()
