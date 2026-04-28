extends Node2D

signal landed

var velocity := Vector2.ZERO
var gravity := 1600.0
var is_airborne := false
var ground_y := 650.0

var landing_success := true
var is_dead := false

@onready var sprite = $Sprite


func _ready():
	is_dead = false
	global_position.y = ground_y
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
			play_land_animation(landing_success)

func dash_to(target_pos:Vector2):
	var start_pos = global_position
	spawn_dash_slash(start_pos, target_pos)
	var dash_dir = (target_pos - start_pos).normalized()
	if dash_dir.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	play_random_attack()
	global_position = target_pos

	is_airborne = true
	velocity = dash_dir * 220
	velocity.y -= 180

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

	is_dead = true
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

	sprite.play("hurt")
	sprite.frame = 0
	await sprite.animation_finished
	sprite.play("idle")
