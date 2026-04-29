extends Node2D

@onready var sprite = $AnimatedSprite2D

var velocity := Vector2.ZERO
var rotation_speed := 0.0

func _ready():
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("default")
	sprite.play("default")
	velocity = Vector2(
		randf_range(500, 900),
		randf_range(-40, 40)
	)

	rotation_speed = randf_range(-6.0, 6.0)

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta
