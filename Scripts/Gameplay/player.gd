extends Node2D

signal landed

var velocity := Vector2.ZERO
var gravity := 1800.0
var is_airborne := false
var ground_y := 650.0

var landing_success := true
var is_dead := false
var death_pending := false

@onready var sprite = $Sprite
var current_skin := ""
var skin_offset_y := 0
var flip_inverted := false

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

var skin_flip_inverted = {
	"WolfSamurai": true,
	"PandaSamurai": true,
	"ExecutionerSamurai": true,
}


func _ready():
	print("Equipped skin:", GameManager.equipped_skin)
	is_dead = false
	global_position.y = ground_y
	apply_skin(GameManager.equipped_skin)
	sprite.play("idle")
	
	
func _process(delta):
	if is_airborne:
		velocity.y += gravity * delta
		position += velocity * delta
		if global_position.y >= ground_y:
			global_position.y = ground_y
			velocity = Vector2.ZERO
			is_airborne = false
			landed.emit()
			SoundManager.play_sfx("land", -15)
			if death_pending:
				start_death_sequence()
			else:
				play_land_animation(landing_success)

func dash_to(target_pos:Vector2):
	var start_pos = global_position
	spawn_dash_slash(start_pos, target_pos)
	var dash_dir = (target_pos - start_pos).normalized()
	var facing_left = dash_dir.x < 0
	if flip_inverted:
		facing_left = !facing_left
	sprite.flip_h = facing_left
	play_random_attack()
	global_position = target_pos

	is_airborne = true
	velocity = dash_dir * 300
	velocity.y -= 100

func spawn_dash_slash(start_pos:Vector2, end_pos:Vector2):
	var scene = preload("res://Scenes/Components/DashSlash.tscn")
	var slash = scene.instantiate()

	get_parent().add_child(slash)
	slash.setup(start_pos, end_pos)
	
func play_random_attack():
	var attacks = ["attack1", "attack2", "attack3"]
	var chosen = attacks[randi() % attacks.size()]
	sprite.play(chosen)
	await sprite.animation_finished
	if is_airborne:
		sprite.play("jump")

func play_land_animation(success:bool):
	if success:
		sprite.play("defend")
	else:
		sprite.play("hurt")
	await sprite.animation_finished
	if not is_airborne and not is_dead:
		sprite.play("idle")
		
func play_death():
	if is_dead:
		return
	if is_airborne:
		death_pending = true
		return
	start_death_sequence()

func start_death_sequence():
	is_dead = true
	death_pending = false
	is_airborne = false
	velocity = Vector2.ZERO

	sprite.play("hurt")
	sprite.frame = 0

	await sprite.animation_finished

	sprite.play("death")
	sprite.frame = 0

func play_hurt():
	if is_dead:
		return
	SoundManager.play_sfx("hurt")
	sprite.play("hurt")
	sprite.frame = 0
	await sprite.animation_finished
	sprite.play("idle")
	

func apply_skin(skin_name:String):
	if skin_name == current_skin:
		return
	current_skin = skin_name
	var path = "res://Assets/SpriteFrames/%s_SpriteFrames.tres" % skin_name
	if ResourceLoader.exists(path):
		sprite.frames = load(path)
		skin_offset_y = skin_offsets.get(skin_name, 0)
		sprite.position.y = skin_offset_y
		flip_inverted = skin_flip_inverted.get(skin_name, false)
	else:
		print("Skin not found:", path)
