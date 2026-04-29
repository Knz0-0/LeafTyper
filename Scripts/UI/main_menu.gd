extends Control

@onready var leaderboard_label = $LeaderboardLabel
@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var coins_label = $CoinsLabel

func _ready():
	MusicManager.play_menu()
	update_leaderboard()
	coins_label.text = "RYO : " + str(GameManager.coins)

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func update_leaderboard():
	var text = ""

	if GameManager.leaderboard.is_empty():
		text = "No scores yet"
	else:
		for i in range(GameManager.leaderboard.size()):
			var entry = GameManager.leaderboard[i]
			text += str(i + 1) + ". " + entry["name"] + " - " + str(entry["score"]) + "\n"

	leaderboard_label.text = text

func _on_play_pressed():
	SoundManager.play_sfx("clash")
	GameManager.start_game()

func _on_settings_pressed():
	print("Settings later")

func _on_credits_pressed():
	print("Made by Kenzo the last-minute legend")

func _on_quit_pressed():
	get_tree().quit()
