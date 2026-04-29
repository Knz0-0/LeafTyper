extends Control

@onready var leaderboard_label = $LeaderboardLabel
@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var coins_label = $CoinsLabel


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

var bg_time := 0.0

func _ready():
	MusicManager.play_menu()
	update_leaderboard()
	coins_label.text = "RYO : " + str(GameManager.coins)

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
func _process(delta):
	bg_time += delta
	update_background()

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
	print("Settings later")

func _on_credits_pressed():
	print("Made by Kenzo the last-minute legend")

func _on_quit_pressed():
	get_tree().quit()

func update_background():
	parallax_layer.scale = Vector2.ONE * (1.0 + sin(bg_time * 0.08) * 0.01)
	parallax_layer2.motion_offset.x += 2 * get_process_delta_time()
	parallax_layer3.motion_offset.x += 3 * get_process_delta_time()
	parallax_layer4.motion_offset.x += 5 * get_process_delta_time()
	parallax_layer5.motion_offset.x += 6 * get_process_delta_time()
	parallax_layer6.motion_offset.x += 8 * get_process_delta_time()
	
	parallax_layer2.motion_offset.y = sin(bg_time * 0.25) * 2
	parallax_layer3.motion_offset.y = sin(bg_time * 0.35) * 3
	parallax_layer4.motion_offset.y = sin(bg_time * 0.45) * 5
	parallax_layer3.motion_offset.y = sin(bg_time * 0.50) * 6
	parallax_layer4.motion_offset.y = sin(bg_time * 0.60) * 8
