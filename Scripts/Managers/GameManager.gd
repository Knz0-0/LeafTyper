extends Node

var current_score : int = 0
var leaderboard : Array = []

var coins := 0
var unlocked_skins = ["samurai3"]
var equipped_skin = "samurai3"

const SAVE_PATH = "user://save.json"

func _ready():
	load_data()

func reset_run():
	current_score = 0

func add_score(value:int):
	current_score += value

func start_game():
	reset_run()
	await TransitionManager.play_transition()
	get_tree().change_scene_to_file("res://Scenes/Gameplay/Game.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	await TransitionManager.fade_back_in()

func return_to_menu():
	await TransitionManager.play_transition()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	await TransitionManager.fade_back_in()

func is_highscore(score:int) -> bool:
	if leaderboard.size() < 5:
		return true
		
	for entry in leaderboard:
		if score > entry["score"]:
			return true
			
	return false

func submit_score(player_name:String, score:int):
	leaderboard.append({
		"name": player_name,
		"score": score
	})
	
	leaderboard.sort_custom(func(a,b): return a["score"] > b["score"])
	
	if leaderboard.size() > 5:
		leaderboard.resize(5)
	
	save_data()

func save_data():
	var data = {
		"leaderboard": leaderboard,
		"coins": coins,
		"unlocked_skins": unlocked_skins,
		"equipped_skin": equipped_skin
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		leaderboard = []
		coins = 0
		unlocked_skins = ["samurai3"]
		equipped_skin = "samurai3"
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file:
		var text = file.get_as_text()
		file.close()

		var result = JSON.parse_string(text)

		if result is Dictionary:
			leaderboard = result.get("leaderboard", [])
			coins = result.get("coins", 0)
			unlocked_skins = result.get("unlocked_skins", ["samurai3"])
			equipped_skin = result.get("equipped_skin", "samurai3")
		else:
			leaderboard = []
			coins = 0
			unlocked_skins = ["samurai3"]
			equipped_skin = "samurai3"
			
func reward_coins_from_run():
	coins += current_score /10
	save_data()
