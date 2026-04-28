extends Control

@onready var leaderboard_label = $LeaderboardLabel

func _ready():
	update_leaderboard()

	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/CreditsButton.pressed.connect(_on_credits_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

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
	GameManager.start_game()

func _on_settings_pressed():
	print("Settings later 😏")

func _on_credits_pressed():
	print("Made by Kenzo the last-minute legend")

func _on_quit_pressed():
	get_tree().quit()
