extends Node2D

@onready var line = $Line2D

var life := 0.12

func setup(start_pos:Vector2, end_pos:Vector2):
	global_position = Vector2.ZERO

	line.clear_points()
	line.add_point(start_pos)
	line.add_point(end_pos)

func _process(delta):
	life -= delta

	modulate.a = life / 0.12

	if life <= 0:
		queue_free()
