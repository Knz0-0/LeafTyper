extends Node

var current_score : int = 0
var leaderboard : Array = []

const SAVE_PATH = "user://save.json"

func _ready():
	load_data()

func reset_run():
	current_score = 0

func add_score(value:int):
	current_score += value

func start_game():
	reset_run()
	get_tree().change_scene_to_file("res://Scenes/Gameplay/Game.tscn")

func return_to_menu():
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")

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
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(leaderboard))
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		leaderboard = []
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		
		var result = JSON.parse_string(text)
		
		if result is Array:
			leaderboard = result
		else:
			leaderboard = []
