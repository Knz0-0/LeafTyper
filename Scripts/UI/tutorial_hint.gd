extends Control

@onready var text = $HintText
@onready var icon = $HintIcon

var steps = []

func _ready():
	steps = [
		["Cut leaves with matching key", preload("res://Assets/Tutorial/hint1.png")],
		["Chain hits in air for combo", preload("res://Assets/Tutorial/hint2.png")],
		["Land to bank your score", preload("res://Assets/Tutorial/hint3.png")]
	]

	play_tutorial()


func play_tutorial():
	for step in steps:
		text.text = step[0]
		icon.texture = step[1]

		modulate.a = 0.0

		var t = create_tween()
		t.tween_property(self, "modulate:a", 1.0, 0.35)

		await get_tree().create_timer(1.6).timeout

		var t2 = create_tween()
		t2.tween_property(self, "modulate:a", 0.0, 0.35)

		await get_tree().create_timer(0.45).timeout

	queue_free()
