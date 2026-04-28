extends Area2D

signal reached_ground
signal destroyed

var letter : String = "A"
var fall_speed : float = 150.0
var ground_y : float = 620.0

@onready var label = $LetterLabel

func _ready():
	label.text = letter

func _process(delta):
	position.y += fall_speed * delta
	
	if global_position.y >= ground_y:
		reached_ground.emit()
		queue_free()

func set_letter(value:String):
	letter = value
	
	if is_node_ready():
		label.text = letter

func destroy_leaf():
	destroyed.emit()
	queue_free()
