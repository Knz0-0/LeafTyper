extends Label

var life := 0.6

func setup(value, is_combo := false):
	if is_combo:
		text = "x" + str(value)
		scale = Vector2(0.9, 0.9)
		modulate = Color.ORANGE
	else:
		text = "+" + str(value)
		modulate = Color.YELLOW

func _process(delta):
	position.y -= 55 * delta
	modulate.a = life / 0.6

	life -= delta

	if life <= 0:
		queue_free()
