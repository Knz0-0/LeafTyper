extends Control

@onready var leaderboard_label = $LeaderboardLabel
@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var coins_label = $CoinsLabel
@onready var skin_button = $PreviewContainer/Button
@onready var skin_preview = $PreviewContainer/Preview

var skin_offsets = {
	"DemonSamurai": -84,
	"ExecutionerSamurai": -60,
	"PandaSamurai": -56,
	"Samurai1": -66,
	"Samurai2": -33,
	"Samurai3": -66,
	"Samurai4": -36,
	"Samurai5": -38,
	"Samurai6": -48,
	"WolfSamurai": -46
}


func _ready():
	MusicManager.play_menu()
	update_leaderboard()
	update_preview()
	coins_label.text = "RYO : " + str(GameManager.coins)

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	skin_button.pressed.connect(_on_preview_pressed)
	


func update_leaderboard():
	var text = ""

	if GameManager.leaderboard.is_empty():
		text = "No scores yet"
	else:
		for i in range(GameManager.leaderboard.size()):
			var entry = GameManager.leaderboard[i]
			text += str(i + 1) + ". " +  entry["name"] + " - " + str(int(entry["score"])) + "\n"

	leaderboard_label.text = text

func _on_play_pressed():
	SoundManager.play_sfx("clash")
	GameManager.start_game()

func _on_settings_pressed():
	SoundManager.play_sfx("clash")
	print("Settings later")

func _on_credits_pressed():
	SoundManager.play_sfx("clash")
	print("Made by Kenzo the last-minute legend")

func _on_quit_pressed():
	SoundManager.play_sfx("clash")
	get_tree().quit()


func update_preview():
	var skin = GameManager.equipped_skin
	var path = "res://Assets/SpriteFrames/%s_SpriteFrames.tres" % skin

	if ResourceLoader.exists(path):
		skin_preview.frames = load(path)
		skin_preview.play("idle")
		var offset = skin_offsets.get(skin, 0)
		skin_preview.position.y = offset * 4 + 350

func _on_preview_pressed():
	SoundManager.play_sfx("clash")
	GameManager.go_to_skins()
