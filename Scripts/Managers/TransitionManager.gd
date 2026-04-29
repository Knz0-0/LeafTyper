extends CanvasLayer

@onready var fade = $Fade
@onready var leaves = $LeavesContainer

var leaf_scene = preload("res://Scenes/Components/TransitionLeaf.tscn")

func _ready():
	visible = false
	fade.color.a = 0.0

func play_transition():
	visible = true
	spawn_leaves()
	await fade_in()


func fade_in():
	var t = 0.0
	var d = 0.35

	while t < d:
		await get_tree().process_frame
		t += get_process_delta_time()
		fade.color.a = lerp(0.0, 1.0, t / d)


func fade_out():
	var t = 0.0
	var d = 0.45

	while t < d:
		await get_tree().process_frame
		t += get_process_delta_time()
		fade.color.a = lerp(1.0, 0.0, t / d)
		
func fade_back_in():
	var t = 0.0
	var d = 0.55

	while t < d:
		await get_tree().process_frame
		t += get_process_delta_time()

		var k = t / d
		k = 1.0 - pow(1.0 - k, 3)

		fade.color.a = lerp(1.0, 0.0, k)

	await remove_leaves_smooth()

	visible = false


func spawn_leaves():
	for i in range(18):
		var leaf = leaf_scene.instantiate()
		leaves.add_child(leaf)

		leaf.position = Vector2(
			randf_range(-300, 1200),
			randf_range(-80, 760)
		)

		leaf.scale = Vector2.ONE * randf_range(1.8, 3.0)


func remove_leaves_smooth():
	for leaf in leaves.get_children():
		var tween = create_tween()

		tween.parallel().tween_property(
			leaf,
			"modulate:a",
			0.0,
			0.25
		)

		tween.parallel().tween_property(
			leaf,
			"position:y",
			leaf.position.y + 40,
			0.25
		)

		tween.finished.connect(leaf.queue_free)

	await get_tree().create_timer(0.28).timeout
